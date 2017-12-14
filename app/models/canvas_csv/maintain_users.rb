module CanvasCsv
  # Updates users currently present within Canvas.
  # Used by CanvasCsv::RefreshAllCampusData to maintain officially enrolled students/faculty
  # See CanvasCsv::AddNewUsers for maintenance of new active CalNet users within Canvas
  class MaintainUsers < Base
    include ClassLogger
    attr_accessor :sis_user_id_changes, :user_email_deletions

    # Returns true if user hashes are identical
    def self.provisioned_account_eq_sis_account?(provisioned_account, sis_account)
      # Canvas interprets an empty 'email' column as 'Do not change.'
      matched = provisioned_account['login_id'] == sis_account['login_id'] &&
        (sis_account['email'].blank? || (provisioned_account['email'] == sis_account['email']))
      if matched && Settings.canvas_proxy.maintain_user_names
        # Canvas plays elaborate games with user name imports. See the RSpec for examples.
        matched = provisioned_account['full_name'] == "#{sis_account['first_name']} #{sis_account['last_name']}"
      end
      matched
    end

    # Updates SIS User ID for Canvas User
    #
    # Because there is no way to do a bulk download of user login objects, two Canvas requests are required to
    # set each user's SIS user ID.
    def self.change_sis_user_id(canvas_user_id, new_sis_user_id)
      logins_proxy = Canvas::Logins.new
      response = logins_proxy.user_logins(canvas_user_id)
      if (user_logins = response[:body])
        # We look for the login with a numeric "unique_id", and assume it is an LDAP UID.
        user_logins.select! do |login|
          parse_login_id(login['unique_id'])[:ldap_uid]
        end
        if user_logins.length > 1
          logger.error "Multiple numeric logins found for Canvas user #{canvas_user_id}; will skip"
        elsif user_logins.empty?
          logger.warn "No LDAP UID login found for Canvas user #{canvas_user_id}; will skip"
        else
          login_object_id = user_logins[0]['id']
          logger.debug "Changing SIS ID for user #{canvas_user_id} to #{new_sis_user_id}"
          response = logins_proxy.change_sis_user_id(login_object_id, new_sis_user_id)
          return true if response[:statusCode] == 200
        end
      end
      false
    end

    def self.parse_login_id(login_id)
      if (matched = /^(inactive-)?([0-9]+)$/.match login_id)
        inactive_account = matched[1]
        ldap_uid = matched[2].to_i
      end
      {
        ldap_uid: ldap_uid,
        inactive_account: inactive_account.present?
      }
    end

    def initialize(known_users, sis_user_import_csv)
      super()
      @known_users = known_users
      @user_import_csv = sis_user_import_csv
      @sis_user_id_changes = {}
      @user_email_deletions = []
    end

    # Appends account changes to the given CSV.
    # Appends all known user IDs to the input array.
    # Makes any necessary changes to SIS user IDs.
    def refresh_existing_user_accounts
      check_all_user_accounts
      handle_changed_sis_user_ids
      if Settings.canvas_proxy.delete_bad_emails.present?
        handle_email_deletions @user_email_deletions
      else
        logger.warn "EMAIL DELETION BLOCKED: Would delete email addresses for #{@user_email_deletions.length} inactive users: #{@user_email_deletions}"
      end
    end

    def check_all_user_accounts
      users_csv_file = "#{Settings.canvas_proxy.export_directory}/provisioned-users-#{DateTime.now.strftime('%F-%H-%M')}.csv"
      users_csv_file = Canvas::Report::Users.new(download_to_file: users_csv_file).get_csv
      if users_csv_file.present?
        accounts_batch = []
        CSV.foreach(users_csv_file, headers: true) do |account_row|
          accounts_batch << account_row
          if accounts_batch.length == 1000
            compare_to_campus(accounts_batch)
            accounts_batch = []
          end
        end
        compare_to_campus(accounts_batch) if accounts_batch.present?
      end
    end

    # Any changes to SIS user IDs must take effect before the enrollments CSV is generated.
    # Otherwise, the generated CSV may include a new ID that does not match the existing ID for a user account.
    def handle_changed_sis_user_ids
      if Settings.canvas_proxy.dry_run_import.present?
        logger.warn "DRY RUN MODE: Would change #{@sis_user_id_changes.length} SIS user IDs #{@sis_user_id_changes.inspect}"
      else
        logger.warn "About to change #{@sis_user_id_changes.length} SIS user IDs"
        @sis_user_id_changes.each do |canvas_user_id, new_sis_id|
          succeeded = self.class.change_sis_user_id(canvas_user_id, new_sis_id)
          unless succeeded
            # If we had ideal data sources, it would be prudent to remove any mention of the no-longer-going-to-be-changed
            # SIS User ID from the import CSVs. However, the failure was likely triggered by Canvas's inconsistent
            # handling of deleted records, with a deleted user login being completely invisible and yet still capable
            # of blocking new records. The only way to make the deleted record available for inspection and clean-up is
            # to go on with the import.
            logger.error "Canvas user #{canvas_user_id} did not successfully have its SIS ID changed to #{new_sis_id}! Check for duplicated LDAP UIDs in bCourses."
          end
        end
      end
    end

    # Instructure interprets a blank 'email' value in an import CSV as 'Leave the existing email alone.'
    # This time-consuming API approach seems to be the only way to remove obsolete email addresses.
    # Also, 'Users can delete their institution-assigned email address' must be enabled in Canvas
    # settings before attempting to delete communication channels.
    def handle_email_deletions(canvas_user_ids)
      logger.warn "About to delete email addresses for #{canvas_user_ids.length} inactive users: #{canvas_user_ids}"
      canvas_user_ids.each do |canvas_user_id|
        proxy = Canvas::CommunicationChannels.new(canvas_user_id: canvas_user_id)
        if (channels = proxy.list[:body])
          channels.each do |channel|
            if channel['type'] == 'email'
              channel_id = channel['id']
              dry_run = Settings.canvas_proxy.dry_run_import
              if dry_run.present?
                logger.warn "DRY RUN MODE: Would delete communication channel #{channel}"
              else
                logger.warn "Deleting communication channel #{channel}"
                proxy.delete channel_id
              end
            end
          end
        end
      end
    end

    def categorize_user_account(existing_account, campus_user_attributes)
      # Convert from CSV::Row for easier manipulation.
      old_account_data = existing_account.to_hash
      parsed_login_id = self.class.parse_login_id old_account_data['login_id']
      ldap_uid = parsed_login_id[:ldap_uid]
      inactive_account = parsed_login_id[:inactive_account]
      if ldap_uid
        campus_user = campus_user_attributes.select { |r| (r[:ldap_uid].to_i == ldap_uid) && !r[:roles][:expiredAccount] }.first
        if campus_user.present?
          logger.warn "Reactivating account for LDAP UID #{ldap_uid}" if inactive_account
          new_account_data = canvas_user_from_campus_attributes campus_user
          @known_users[ldap_uid.to_s] = new_account_data['user_id']
        else
          # Check to see if there are obsolete email addresses to (potentially) delete.
          if old_account_data['email'].present? &&
            (inactive_account || Settings.canvas_proxy.inactivate_expired_users)
            @user_email_deletions << old_account_data['canvas_user_id']
          end
          if Settings.canvas_proxy.inactivate_expired_users
            # This LDAP UID no longer appears in campus data. Mark the Canvas user account as inactive.
            logger.warn "Inactivating account for LDAP UID #{ldap_uid}" unless inactive_account
            new_account_data = old_account_data.merge(
              'login_id' => "inactive-#{ldap_uid}",
              'user_id' => "UID:#{ldap_uid}",
              'email' => nil
            )
            @known_users[ldap_uid.to_s] = new_account_data['user_id']
          else
            @known_users[ldap_uid.to_s] = old_account_data['user_id']
            return
          end
        end
        if old_account_data['user_id'] != new_account_data['user_id']
          logger.warn "Will change SIS ID for user sis_login_id:#{old_account_data['login_id']} from #{old_account_data['user_id']} to #{new_account_data['user_id']}"
          @sis_user_id_changes["sis_login_id:#{old_account_data['login_id']}"] = new_account_data['user_id']
        end
        unless self.class.provisioned_account_eq_sis_account?(old_account_data, new_account_data)
          @user_import_csv << new_account_data
        end
      end
    end

    def compare_to_campus(accounts_batch)
      campus_user_rows = User::BasicAttributes.attributes_for_uids(accounts_batch.collect do |r|
          r['login_id'].to_s.gsub(/^inactive-/, '')
        end
      )
      accounts_batch.each do |existing_account|
        categorize_user_account(existing_account, campus_user_rows)
      end
    end

  end
end

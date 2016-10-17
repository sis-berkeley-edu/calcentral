module MailingLists
  class MailgunList < SiteMailingList

    # Mailgun lists have membership stored locally and are considered 'created' as soon as they're saved.
    has_many :members, class_name: 'MailingLists::Member', foreign_key: 'mailing_list_id'
    before_create { self.state = 'created' }

    def self.domain
      Settings.mailgun_proxy.domain
    end

    def add_list_urls(feed)
      # No-op; Mailgun lists have no external administration URLs.
    end

    def add_member(address, first_name, last_name, can_send)
      MailingLists::Member.create!(
        email_address: address,
        first_name: first_name,
        last_name: last_name,
        can_send: can_send,
        mailing_list_id: self.id
      )
    rescue => e
      logger.error "Failed to add #{address} to mailing list #{self.list_name}: #{e.message}\n\t#{e.backtrace.join "\n\t"}"
      false
    end

    def get_list_members
      self.members.inject({}) { |members_by_email, member| members_by_email[member.email_address] = member; members_by_email }
    end

    def log_population_results
      self.members_count = self.members.count

      logger.info "Added #{population_results[:add][:success]} of #{population_results[:add][:total]} new site members."
      if population_results[:add][:failure].any?
        logger.error "Failed to add #{population_results[:add][:failure].count} addresses to #{self.list_name}: #{population_results[:add][:failure].join ', '}"
      end

      logger.info "Removed #{population_results[:remove][:success]} of #{population_results[:remove][:total]} former site members."
      if population_results[:remove][:failure].any?
        logger.error "Failed to remove #{population_results[:remove][:failure].count} addresses from #{self.list_name}: #{population_results[:remove][:failure].join ', '}"
      end

      logger.info "Updated #{population_results[:update][:success]} of #{population_results[:update][:total]} new site members."
      if population_results[:update][:failure].any?
        logger.error "Failed to update #{population_results[:update][:failure].count} addresses in #{self.list_name}: #{population_results[:update][:failure].join ', '}"
      end
    end

    def name_available?
      MailingLists::SiteMailingList.find_by(list_name: self.list_name).nil?
    end

    def remove_member(address)
      if (member = self.members.find_by email_address: address)
        member.destroy
      end
    end

    def update_member(member, course_user_data)
      member.update_attributes course_user_data.slice(:first_name, :last_name, :can_send)
    end

    def update_required?(member, course_user_data)
      [:first_name, :last_name, :can_send].any? { |attr| course_user_data[attr] != member.send(attr) }
    end
  end
end

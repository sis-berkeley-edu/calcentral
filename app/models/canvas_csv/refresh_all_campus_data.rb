module CanvasCsv

  # Generates and imports SIS User and Enrollment CSV dumps into Canvas based on campus SIS information.
  class RefreshAllCampusData < Base
    attr_accessor :users_csv_filename
    attr_accessor :term_to_memberships_csv_filename
    include Zipper

    def initialize(accounts_or_all='all')
      super()
      if Settings.canvas_proxy.import_zipped_csvs
        @sis_ids_csv_filename = "#{@export_dir}/canvas-#{DateTime.now.strftime('%F')}-sis-ids.csv"
      end
      @users_csv_filename = "#{@export_dir}/canvas-#{DateTime.now.strftime('%F')}-users-#{accounts_or_all}.csv"
      @accounts_only = (accounts_or_all == 'accounts')
      unless @accounts_only
        @term_to_memberships_csv_filename = {}
        term_ids = Canvas::Terms.current_sis_term_ids
        term_ids.each do |term_id|
          csv_filename = "#{@export_dir}/canvas-#{DateTime.now.strftime('%F')}-#{file_safe(term_id)}-enrollments-#{accounts_or_all}.csv"
          @term_to_memberships_csv_filename[term_id] = csv_filename
        end
      end
    end

    def run
      make_csv_files
      if Settings.canvas_proxy.import_zipped_csvs
        import_zipped_csv_files
      else
        import_single_csv_files
      end
    end

    def make_csv_files
      users_csv = make_users_csv(@users_csv_filename)
      sis_ids_csv = make_sis_ids_csv(@sis_ids_csv_filename) if @sis_ids_csv_filename
      known_users = {}
      user_maintainer = MaintainUsers.new(known_users, users_csv, sis_ids_csv)
      user_maintainer.refresh_existing_user_accounts
      if @sis_ids_csv_filename
        sis_ids_csv.close
        @sis_ids_csv_filename = nil if csv_count(@sis_ids_csv_filename) == 0
      end
      original_user_count = known_users.length
      unless @accounts_only
        cached_enrollments_provider = CanvasCsv::TermEnrollments.new
        @term_to_memberships_csv_filename.each do |term, csv_filename|
          enrollments_csv = make_enrollments_csv(csv_filename)
          refresh_existing_term_sections(term, enrollments_csv, known_users, users_csv, cached_enrollments_provider, user_maintainer.sis_user_id_changes)
          enrollments_csv.close
          enrollments_count = csv_count(csv_filename)
          logger.warn "Will upload #{enrollments_count} Canvas enrollment records for #{term}"
          @term_to_memberships_csv_filename[term] = nil if enrollments_count == 0
        end
      end
      new_user_count = known_users.length - original_user_count
      users_csv.close
      updated_user_count = csv_count(@users_csv_filename) - new_user_count
      logger.warn "Will upload #{updated_user_count} changed accounts for #{original_user_count} existing users"
      logger.warn "Will upload #{new_user_count} new user accounts"
      @users_csv_filename = nil if (updated_user_count + new_user_count) == 0
    end

    def refresh_existing_term_sections(term, enrollments_csv, known_users, users_csv, cached_enrollments_provider, sis_user_id_changes)
      canvas_sections_csv = Canvas::Report::Sections.new.get_csv(term)
      return if canvas_sections_csv.nil? || canvas_sections_csv.empty?
      # Instructure doesn't guarantee anything about sections-CSV ordering, but we need to group sections
      # together by course site.
      course_id_to_csv_rows = canvas_sections_csv.group_by {|row| row['course_id']}
      course_id_to_csv_rows.each do |course_id, csv_rows|
        logger.debug "Refreshing Course ID #{course_id}"
        if course_id.present?
          sis_section_ids = csv_rows.collect { |row| row['section_id'] }
          sis_section_ids.delete_if {|section| section.blank? }
          # Process using cached enrollment data. See CanvasCsv::TermEnrollments
          CanvasCsv::SiteMembershipsMaintainer.process(course_id, sis_section_ids, enrollments_csv, users_csv, known_users, cached_enrollments_provider, sis_user_id_changes)
        end
        logger.debug "Finished processing refresh for Course ID #{course_id}"
      end
    end

    def import_single_csv_files
      import_proxy = Canvas::SisImport.new
      if @sis_ids_csv_filename.present? && import_proxy.import_sis_ids(@sis_ids_csv_filename)
        logger.warn 'SIS IDs import succeeded'
      end
      if @users_csv_filename.blank? || import_proxy.import_users(@users_csv_filename)
        logger.warn 'User import succeeded'
        unless @accounts_only
          @term_to_memberships_csv_filename.each do |term_id, csv_filename|
            if csv_filename.present?
              if import_proxy.import_all_term_enrollments(csv_filename)
                logger.warn "Incremental enrollment import for #{term_id} succeeded"
              else
                logger.error "Incremental enrollment import for #{term_id} failed"
              end
            end
          end
        end
      end
    end

    def enrollments_import_safe?
      threshold = Settings.canvas_proxy.max_deleted_enrollments
      if threshold > 0
        for csv_file in @term_to_memberships_csv_filename.values
          if csv_file.present?
            enrollments_csv = CSV.read(csv_file, {headers: true})
            drops = enrollments_csv.count {|r| r['status'] == 'deleted'}
            if drops > threshold
              logger.error "Enrollments import #{csv_file} has #{drops} deletions; max is #{threshold}"
              return false
            end
          end
        end
      end
      return true
    end

    def import_zipped_csv_files
      import_proxy = Canvas::SisImport.new
      import_files = [@sis_ids_csv_filename, @users_csv_filename]
      unless @accounts_only
        import_files.concat @term_to_memberships_csv_filename.values
      end
      import_files.reject! { |f| f.blank? }
      if import_files.blank?
        logger.warn "No CSV files to import"
        return
      end
      import_type = @accounts_only ? 'accounts' : 'all'
      zipped_csv_filename = "#{@export_dir}/canvas-#{DateTime.now.strftime('%F_%H%M%S')}-incremental_#{import_type}.zip"
      zip_flattened(import_files, zipped_csv_filename)

      unless @accounts_only
        if !enrollments_import_safe?
          logger.error "Will not automatically import #{zipped_csv_filename}; import manually if desired"
          return
        end
      end

      if import_proxy.import_zipped zipped_csv_filename
        logger.warn "Import of #{zipped_csv_filename} succeeded, incorporating #{import_files}"
      else
        logger.error "Failed import of #{zipped_csv_filename}, incorporating #{import_files}"
      end
    end

  end
end

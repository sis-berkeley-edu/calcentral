module CanvasCsv
  # Adds Canvas users based on differences detected in active CalNet user set and Canvas User Report
  class AddNewUsers < Base
    require 'set'

    # Performs full new user detection and addition task
    def sync_new_active_users
      prepare_sis_user_import
      get_canvas_user_report_file
      load_new_active_users
      if @new_active_sis_users.count > 0
        process_new_users
        import_sis_user_csv
      else
        logger.warn 'No new user accounts detected. New user processing completed.'
      end
    end

    def prepare_sis_user_import
      sis_user_import_filename = "#{@export_dir}/canvas-#{DateTime.now.strftime('%F_%H-%M-%S')}-sync-all-users.csv"
      @sis_user_import = make_users_csv sis_user_import_filename
    end

    # Prepares Canvas report containing all users for iteration during processing
    def get_canvas_user_report_file
      get_report = Proc.new do
        filename = "#{@export_dir}/canvas-#{DateTime.now.strftime('%F_%H-%M-%S')}-users-report.csv"
        csv_table = Canvas::Report::Users.new.get_csv
        headers = csv_table.headers.join(',')
        file = CSV.open(filename, 'wb', headers: headers, write_headers: true)
        logger.warn "Canvas user report obtained containing data on #{csv_table.count} user accounts"
        csv_table.each do |row|
          file << row
        end
        file.close
        file.path
      end
      @canvas_user_report_file_path ||= get_report.call
    end

    def load_new_active_users
      @new_active_sis_users = []
      new_active_user_uids.each_slice(1000) do |uid_group|
        @new_active_sis_users.concat User::BasicAttributes.attributes_for_uids(uid_group)
      end
      @new_active_sis_users
    end

    # Add remaining users not detected in Canvas to SIS User Import
    def process_new_users
      logger.warn "#{@new_active_sis_users.length} new user accounts detected. Adding to SIS User Import CSV"
      @new_active_sis_users.each do |new_user|
        new_canvas_user = canvas_user_from_campus_attributes new_user
        add_user_to_import new_canvas_user
      end
      @new_active_sis_users = nil
    end

    def import_sis_user_csv
      @sis_user_import.close
      csv_filepath = @sis_user_import.path
      user_count = CSV.read(csv_filepath, headers: true).length
      if user_count > 0
        logger.warn "Importing SIS User Import CSV with #{user_count} updates"
        Canvas::SisImport.new.import_users csv_filepath
      end
    end

    # Loads array of new active LDAP people/guests from campus Oracle view
    def new_active_user_uids
      rows = EdoOracle::Bcourses.get_all_active_people_uids
      all_active_sis_user_uids = rows.to_set
      all_current_canvas_uids = []
      CSV.foreach(get_canvas_user_report_file, headers: :first_row) do |canvas_user|
        if (existing_ldap_uid = MaintainUsers.parse_login_id(canvas_user['login_id'])[:ldap_uid])
          all_current_canvas_uids << existing_ldap_uid.to_s
        end
      end
      all_active_sis_user_uids.subtract(all_current_canvas_uids).to_a
    end

    # Adds Canvas User hash to SIS User Import CSV
    def add_user_to_import(canvas_user)
      @sis_user_import << canvas_user
    end

  end
end

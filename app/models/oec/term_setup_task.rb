module Oec
  class TermSetupTask < Task

    def run_internal
      log :info, "Will create initial folders and files for term #{@term_code}"

      term_folder = create_folder @term_code
      term_subfolders = {}
      Oec::Folder::FOLDER_TITLES.each do |folder_type, folder_name|
        term_subfolders[folder_type] = create_folder(folder_name, term_folder)
      end

      previous_term_csvs = find_previous_term_csvs
      [Oec::CourseInstructors, Oec::CourseSupervisors, Oec::Instructors, Oec::Supervisors].each do |worksheet_class|
        file = previous_term_csvs[worksheet_class]
        if file && (file.mime_type == 'text/csv') && file.download_url
          content = StringIO.new @remote_drive.download(file)
          @remote_drive.upload_to_spreadsheet(file.title.chomp('.csv'), content, term_subfolders[:overrides].id)
        elsif file
          copy_file(file, term_subfolders[:overrides])
        else
          log :info, "Could not find previous sheet '#{worksheet_class.export_name}' for copying; will create header-only file"
          export_sheet_headers(worksheet_class, term_subfolders[:overrides])
        end
      end

      courses = Oec::Courses.new
      set_default_term_dates courses
      export_sheet(courses, term_subfolders[:overrides])

      if !@opts[:local_write] && (department_template = @remote_drive.find_nested ['templates', 'Department confirmations'])
        @remote_drive.copy_item_to_folder(department_template, term_subfolders[:confirmations].id, 'TEMPLATE')
      end
    end

    def find_previous_term_csvs
      csvs = {}
      if (previous_term_folder = find_previous_term_folder)
        if (previous_overrides = @remote_drive.find_first_matching_folder(Oec::Folder.overrides, previous_term_folder))
          csvs[Oec::Instructors] = @remote_drive.find_first_matching_item('instructors', previous_overrides)
          csvs[Oec::Supervisors] = @remote_drive.find_first_matching_item('supervisors', previous_overrides)
        end
        if (previous_term_last_export = find_last_export previous_term_folder)
          csvs[Oec::CourseInstructors] = find_csv_in_folder(previous_term_last_export, 'course_instructors.csv')
          csvs[Oec::CourseSupervisors] = find_csv_in_folder(previous_term_last_export, 'course_supervisors.csv')
        end
      end
      csvs
    end

    def set_default_term_dates(courses)
      term = Berkeley::Terms.fetch.campus[Berkeley::TermCodes.to_slug *@term_code.split('-')]
      courses[0] = {
        'START_DATE' => @term_start.strftime(Oec::Worksheet::WORKSHEET_DATE_FORMAT),
        'END_DATE' => @term_end.strftime(Oec::Worksheet::WORKSHEET_DATE_FORMAT)
      }
    end
  end
end

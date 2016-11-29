describe 'My Academics Final Exams card', :testui => true do

  if ENV['UI_TEST'] && Settings.ui_selenium.layer == 'local'

    include ClassLogger

    begin
      @driver = WebDriverUtils.launch_browser
      @splash_page = CalCentralPages::SplashPage.new @driver
      @exams_card = CalCentralPages::MyAcademicsPage::MyAcademicsFinalExamsCard.new @driver
      @student_api = ApiEdosStudentPage.new @driver
      @academics_api = ApiMyAcademicsPageSemesters.new @driver
      @registrations_api = ApiMyRegistrationsPage.new @driver

      test_users = UserUtils.load_test_users.select { |user| user['finalExams'] }
      testable_users = []
      test_output_heading = %w(UID Term Date Time Course Location)
      test_output = UserUtils.initialize_output_csv(self, test_output_heading)

      test_users.each do |user|
        uid = user['uid']
        logger.info "UID is #{uid}"

        has_exams_card = nil

        begin
          @splash_page.load_page
          @splash_page.basic_auth uid

          # Get data from API endpoints
          @student_api.get_json @driver
          @academics_api.get_json @driver
          @registrations_api.get_json @driver

          # Check if the user has a Final Exams card
          @exams_card.load_page
          has_exams_card = WebDriverUtils.verify_block { @exams_card.final_exams_card_heading_element.when_present WebDriverUtils.page_load_timeout }

          if @academics_api.exam_semesters.any?

            it("shows a Final Exams card for UID #{uid}") { expect(has_exams_card).to be true }

            if @academics_api.exam_schedules && @academics_api.exam_schedules.any?

              testable_users << uid

              @academics_api.exam_semesters.each do |term|
                term_name = @academics_api.exam_schedule_term_name term
                logger.info "Checking exams for #{term_name}"

                it("shows no summer exam data for UID #{uid}") { expect(term_name).not_to include('Summer') }

                # COURSES AND EXAMS
                courses = @academics_api.semester_courses term
                api_course_codes = @academics_api.semester_card_course_codes(@academics_api.all_student_semesters, term, courses)
                api_exam_course_codes = @academics_api.term_exam_course_codes term
                it("shows all the expected courses for UID #{uid} in #{term_name}") { expect(api_exam_course_codes).to eql(api_course_codes) }

                api_exams = @academics_api.term_exams term
                ui_exams = @exams_card.term_exams term_name
                it("shows the expected final exams for UID #{uid} in #{term_name}") { expect(ui_exams).to eql(api_exams) }

                # EXAM CONFLICTS
                has_conflict = @academics_api.has_conflicts? term
                has_conflict_alert = @exams_card.exam_conflict(term_name).any?
                logger.warn "UID #{uid} has an exam conflict in #{term_name}" if has_conflict

                has_conflict ?
                    (it("shows an exam conflict alert for UID #{uid} in #{term_name}") { expect(has_conflict_alert).to be true }) :
                    (it("shows no exam conflict alert for UID #{uid} in #{term_name}") { expect(has_conflict_alert).to be false })

                # EXAM DATA SOURCE
                has_cs_data = @academics_api.term_cs_data_available? term
                has_disclaimer = WebDriverUtils.verify_block { @exams_card.disclaimer(@driver, term_name) }

                if term == @academics_api.current_semester(@academics_api.all_student_semesters)

                  # Eight weeks prior to the end of semester, the exam data source changes
                  end_date = @registrations_api.term_end_date @registrations_api.current_term
                  today = DateTime.now.to_date

                  if end_date - today < 56
                    it("shows CS exam data for UID #{uid} in #{term_name}") { expect(has_cs_data).to be true }
                    it("shows no disclaimer for UID #{uid} in #{term_name}") { expect(has_disclaimer).to be false }
                  else
                    it("shows CSV exam data for UID #{uid} in #{term_name}") { expect(has_cs_data).to be false }
                    it("shows a disclaimer for UID #{uid} in #{term_name}") { expect(has_disclaimer).to be true }
                  end

                else
                  it("shows CSV exam data for UID #{uid} in #{term_name}") { expect(has_cs_data).to be false }
                  it("shows a disclaimer for UID #{uid} in #{term_name}") { expect(has_disclaimer).to be true }
                end

                # SANITY TESTS
                ui_exams.each do |exam|
                  date = exam[1]
                  location = exam[4]

                  if has_cs_data
                    if date.blank?
                      it("shows either 'No exam' or 'Location TBD' for an unscheduled #{ui_exams[3]} exam for UID #{uid} in #{term_name}") { expect(['No exam.', 'Location TBD']).to include(location) }
                    else
                      it("does not show 'No exam' for a scheduled #{ui_exams[3]} exam for UID #{uid} in #{term_name}") { expect(location).to_not include('No exam') }
                    end
                  else
                    it("shows nothing for location for a #{ui_exams[3]} exam where CS data is not yet available for UID #{uid} in #{term_name}") { expect(location).to be_blank }
                  end

                  if location.present? && !['No exam.', 'Location TBD'].include?(location)
                    it("shows a #{ui_exams[3]} exam date if a scheduled exam location exists for UID #{uid} in #{term_name}") { expect(date).to_not be_blank }
                  end
                end

                api_exams.each do |exam|
                  test_output_row = [uid, exam[0], exam[1], exam[2], exam[3], exam[4]]
                  UserUtils.add_csv_row(test_output, test_output_row)
                end
              end
            end
          else

            it("shows no final exams card for UID #{uid}") { expect(has_exams_card).to be false }

          end
        rescue => e
          it("caused an unexpected error in the test for UID #{uid}") { fail }
          logger.error "#{e.message}'\n' #{ e.backtrace.join("\n")}"
        end
      end

      it('has final exams info for at least one of the test UIDs') { expect(testable_users.any?).to be true }

    rescue => e
      logger.error "#{e.message}'\n' #{ e.backtrace.join("\n")}"
    ensure
      WebDriverUtils.quit_browser @driver
    end
  end
end

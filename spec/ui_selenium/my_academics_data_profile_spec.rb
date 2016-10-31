describe 'My Academics profile card', :testui => true do

  if ENV["UI_TEST"] && Settings.ui_selenium.layer != 'production'

    include ClassLogger

    begin
      driver = WebDriverUtils.launch_browser
      test_users = UserUtils.load_test_users.select { |user| user['profile'] }
      testable_users = []
      test_output_heading = ['UID', 'Term Transition', 'Colleges', 'Majors', 'Careers', 'Units', 'GPA', 'Level']
      test_output = UserUtils.initialize_output_csv(self, test_output_heading)

      splash_page = CalCentralPages::SplashPage.new driver
      status_api_page = ApiMyStatusPage.new driver
      academics_api_page= ApiMyAcademicsPageSemesters.new driver
      profile_card = CalCentralPages::MyAcademicsProfileCard.new driver

      test_users.each do |user|
        uid = user['uid']
        logger.info "UID is #{uid}"
        term_transition = false
        api_colleges = []
        api_majors = []
        api_careers = []
        api_units = nil
        api_gpa = nil
        api_level = nil

        begin
          splash_page.load_page
          splash_page.basic_auth uid
          status_api_page.get_json driver
          academics_api_page.get_json driver
          profile_card.load_page

          if (status_api_page.has_academics_tab? && status_api_page.is_student?) || status_api_page.has_student_history? || status_api_page.is_applicant?

            profile_card.profile_card_element.when_visible WebDriverUtils.academics_timeout
            testable_users << uid unless academics_api_page.transition_term?

            # NAME
            api_full_name = status_api_page.full_name
            my_academics_full_name = profile_card.name
            it ("show the full name of UID #{uid}") { expect(my_academics_full_name).to eql(api_full_name) }

            # GPA
            if %w(0.0 0).include?(academics_api_page.gpa) || academics_api_page.gpa.nil? || status_api_page.is_concurrent_enroll_student?
              has_gpa = profile_card.gpa?
              it ("show no GPA for UID #{uid}") { expect(has_gpa).to be false }
            else
              api_gpa = academics_api_page.gpa
              shows_gpa = profile_card.gpa_element.visible?
              it ("hide the GPA by default for UID #{uid}") { expect(shows_gpa).to be false }

              profile_card.show_gpa
              gpa_revealed = profile_card.gpa_element.when_visible WebDriverUtils.page_event_timeout
              my_academics_gpa = profile_card.gpa
              it "show the GPA for UID #{uid} when a user clicks 'Show'" do
                expect(gpa_revealed).to be_truthy
                expect(my_academics_gpa).to eql(api_gpa)
              end

              profile_card.hide_gpa
              gpa_hidden = profile_card.gpa_element.when_not_visible WebDriverUtils.page_event_timeout
              it ("hide the GPA for UID #{uid} when a user clicks 'Hide'") { expect(gpa_hidden).to be_truthy }
            end

            # UNITS
            if academics_api_page.ttl_units.nil? || academics_api_page.ttl_units.zero?
              has_units = profile_card.units?
              it ("show no units for UID #{uid}") { expect(has_units).to be false }
            else
              api_units = academics_api_page.ttl_units.to_s
              my_academics_units = profile_card.units
              it ("show the units for UID #{uid}") { expect(my_academics_units).to eql(api_units) }
            end

            # STANDING
            unless academics_api_page.has_no_standing?

              api_colleges = academics_api_page.colleges
              api_majors = academics_api_page.majors
              api_careers = academics_api_page.careers
              my_academics_colleges = profile_card.all_colleges
              my_academics_majors = profile_card.all_majors
              my_academics_careers = profile_card.all_careers

              it ("show the colleges for UID #{uid}") { expect(my_academics_colleges).to eql(api_colleges) }
              it ("show the majors for UID #{uid}") { expect(my_academics_majors).to eql(api_majors) }
              it ("show the careers for UID #{uid}") { expect(my_academics_careers).to eql(api_careers) }

              if api_careers.include? 'Graduate'
                it ("do not show 'College of Letters & Science' for grad student UID #{uid}") { expect(my_academics_colleges).not_to include('College of Letters & Science') }
              end

              # LEVEL
              api_level = academics_api_page.level
              if api_level.nil?
                has_level = profile_card.level?
                it ("show no level for UID #{uid}") { expect(has_level).to be false }
              else
                my_academics_level = profile_card.level
                it ("show the level for UID #{uid}") { expect(my_academics_level).to eql(api_level) }
              end
            end

            # STUDENT STATUS MESSAGING VARIATIONS

            if academics_api_page.has_no_standing?

              has_reg_no_standing_msg = profile_card.reg_no_standing_msg?
              has_non_reg_msg = profile_card.non_reg_student_msg?
              has_new_student_msg = profile_card.new_student_msg?
              has_concur_student_msg = profile_card.concur_student_msg?
              has_ex_student_msg = profile_card.ex_student_msg?

              if status_api_page.is_student?
                if status_api_page.is_registered?
                  it ("show a registered but not fully active message to UID #{uid}") { expect(has_reg_no_standing_msg).to be true }
                else
                  if academics_api_page.units_attempted == 0
                    it ("show a 'not registered' message to UID #{uid}") { expect(has_non_reg_msg).to be true }
                    it ("show a new student message to UID #{uid}") { expect(has_new_student_msg).to be true }
                  else
                    it ("show a 'not registered' message to UID #{uid}") { expect(has_non_reg_msg).to be true }
                  end
                end

              elsif status_api_page.is_concurrent_enroll_student?
                has_uc_ext_link = WebDriverUtils.verify_external_link(driver, profile_card.uc_ext_link_element, 'Concurrent Enrollment | Student Services | UC Berkeley Extension')
                has_eap_link = WebDriverUtils.verify_external_link(driver, profile_card.eap_link_element, 'Exchange Students | Berkeley International Office')
                it ("show a concurrent enrollment student message to UID #{uid}") { expect(has_concur_student_msg).to be true }
                it ("show a concurrent enrollment UC Extension link to UID #{uid}") { expect(has_uc_ext_link).to be true }
                it ("show a concurrent enrollment EAP link to UID #{uid}") { expect(has_eap_link).to be true }

              elsif status_api_page.is_ex_student?
                it ("show an ex-student message to UID #{uid}") { expect(has_ex_student_msg).to be true }
              else
                it "shows no messages to UID #{uid}" do
                  expect(has_reg_no_standing_msg).to be false
                  expect(has_non_reg_msg).to be false
                  expect(has_new_student_msg).to be false
                  expect(has_concur_student_msg).to be false
                  expect(has_ex_student_msg).to be false
                end
              end

            else

              if academics_api_page.transition_term? && !academics_api_page.trans_term_profile_current?
                term_transition = true
                api_term_transition = "Academic status as of #{academics_api_page.term_name}"
                if status_api_page.is_student?
                  my_academics_term_transition = profile_card.term_transition_heading
                  it ("show the term transition heading to UID #{uid}") { expect(my_academics_term_transition).to eql(api_term_transition) }
                else
                  has_transition_heading = profile_card.term_transition_heading?
                  it ("shows no term transition heading to UID #{uid}") { expect(has_transition_heading).to be false }
                end
              end
            end

          elsif academics_api_page.all_teaching_semesters.nil?

            no_data_msg = profile_card.not_found_element.when_visible WebDriverUtils.page_load_timeout
            it ("show a 'Data not available' message to UID #{uid}") { expect(no_data_msg).to be_truthy }

          else

            has_profile_card = profile_card.profile_card?
            it ("show no profile card to UID #{uid}") { expect(has_profile_card).to be false }
          end

        rescue => e
          logger.error "#{e.message + "\n"} #{e.backtrace.join("\n ")}"
        ensure
          test_output_row = [uid, term_transition, api_colleges * '; ', api_majors * '; ', api_careers * '; ',
                             api_units, api_gpa, api_level]
          UserUtils.add_csv_row(test_output, test_output_row)
        end
      end

      it ('shows academic profile for a current term for at least one of the test UIDs') { expect(testable_users.any?).to be true }

    rescue => e
      logger.error "#{e.message + "\n"} #{e.backtrace.join("\n ")}"
    ensure
      WebDriverUtils.quit_browser driver
    end
  end
end

describe 'Delegated access', :testui => true do

  if ENV['UI_TEST'] && Settings.ui_selenium.layer != 'production'

    include ClassLogger

    begin
      @driver = WebDriverUtils.launch_browser
      timeout = WebDriverUtils.page_load_timeout
      wait = Selenium::WebDriver::Wait.new :timeout => timeout

      @splash_page = CalCentralPages::SplashPage.new @driver
      @cal_net_page = CalNetAuthPage.new @driver
      @dashboard_page = CalCentralPages::MyDashboardPage.new @driver
      @campus_page = CalCentralPages::MyCampusPage.new @driver
      @toolbox_page = CalCentralPages::MyToolboxPage.new @driver
      @delegate_welcome = CalCentralPages::DelegateWelcomeCard.new @driver

      @cs_delegate_students_api = ApiCSDelegateAccessStudents.new @driver
      @status_api = ApiMyStatusPage.new @driver
      @academics_api = ApiMyAcademicsPageSemesters.new @driver
      @financials_api = ApiMyFinancialsPage.new @driver
      @cs_fin_aid_years_api = ApiCSAidYearsPage.new @driver

      # Academics UI
      @academic_profile_card = CalCentralPages::MyAcademicsProfileCard.new @driver
      @status_card = CalCentralPages::MyAcademicsStatusAndHoldsCard.new @driver
      @semester_card = CalCentralPages::MyAcademicsSemestersCard.new @driver
      @final_exams_card = CalCentralPages::MyAcademicsFinalExamsCard.new @driver
      @final_grades_card = CalCentralPages::MyAcademicsFinalGradesCard.new @driver
      @gpa_calc_card = CalCentralPages::MyAcademicsGPACalcCard.new @driver
      @classes_card = CalCentralPages::MyAcademicsClassesCard.new @driver
      @teaching_card = CalCentralPages::MyAcademicsTeachingCard.new @driver
      @class_page = CalCentralPages::MyAcademicsClassPage.new @driver
      @booklist_page = CalCentralPages::MyAcademicsBookListPage.new @driver

      # Finances UI
      @finances_page = CalCentralPages::MyFinancesPages::MyFinancesLandingPage.new @driver
      @finances_details_page = CalCentralPages::MyFinancesPages::MyFinancesDetailsPage.new @driver
      @finances_fin_aid_page = CalCentralPages::MyFinancesPages::MyFinancesFinancialAidPage.new @driver

      # Profile UI
      @profile_basic = CalCentralPages::MyProfileBasicInfoCard.new @driver
      @profile_contact = CalCentralPages::MyProfileContactInfoCard.new @driver
      @profile_demographic = CalCentralPages::MyProfileDemographicCard.new @driver
      @profile_delegate = CalCentralPages::MyProfileDelegateAccessCard.new @driver
      @profile_disclosure = CalCentralPages::MyProfileInfoDisclosureCard.new @driver
      @profile_title_iv = CalCentralPages::MyProfileTitleIVCard.new @driver
      @profile_bconnected = CalCentralPages::MyProfileBconnectedCard.new @driver

      test_output_heading = ['UID', 'Student UID', 'Student', 'Faculty', 'Staff', 'Enrollment', 'Grades', 'Financial', 'Phone']
      test_output = UserUtils.initialize_output_csv(self, test_output_heading)

      test_delegates = UserUtils.load_test_users.select { |user| user['delegatedAccess'] }
      test_delegates.each do |delegate|

        begin
          uid = delegate['uid']
          logger.info "Delegate UID is #{uid}"
          @splash_page.load_page
          # End view-as session left over from previous loop
          @splash_page.delegate_stop_viewing
          @splash_page.basic_auth uid

          @cs_delegate_students_api.get_json @driver
          students = @cs_delegate_students_api.students

          if students.nil?

            logger.warn "Delegate UID #{uid} has no students"

            blocks_toolbox = WebDriverUtils.verify_block do
              @toolbox_page.load_page
              @toolbox_page.not_found_element.when_present timeout
            end
            it ("prevents UID #{uid} from reaching the Toolbox") { expect(blocks_toolbox).to be true }

          else

            logger.info "There are #{students.length} student accounts associated with delegate UID #{uid}"

            # DELEGATED ACCESS UI ON TOOLBOX PAGE

            @toolbox_page.load_page

            shows_delegate_welcome = WebDriverUtils.verify_block do
              @toolbox_page.delegate_msg_heading_element.when_visible timeout
              @toolbox_page.delegate_msg_element.when_visible timeout
            end
            it ("shows delegate UID #{uid} the delegate welcome message") { expect(shows_delegate_welcome).to be true }

            # Check page links for one of the test delegates

            if delegate == test_delegates.first

              shows_less = @toolbox_page.delegate_msg_expanded_element.visible?
              it ("shows delegate UID #{uid} a collapsed view of delegate instructions") { expect(shows_less).to be false }

              @toolbox_page.show_more
              shows_more = @toolbox_page.delegate_msg_expanded_element.visible?
              it ("shows delegate UID #{uid} an expanded view of delegate instructions") { expect(shows_more).to be true }

              ui_students = @toolbox_page.all_delegator_names
              api_students = @cs_delegate_students_api.student_names
              it ("shows delegate UID #{uid} the list of linked students") { expect(ui_students).to eql(api_students) }

              subscribe_calendar_link = WebDriverUtils.verify_external_link(@driver, @toolbox_page.subscribe_to_calendar_element, 'Calendar | Office of the Registrar')
              it ("shows delegate UID #{uid} a link to 'Subscribe to the Academic Calendar'") { expect(subscribe_calendar_link).to be true }

              grad_div_calendar_link = WebDriverUtils.verify_external_link(@driver, @toolbox_page.grad_div_deadlines_element, 'Degree Deadlines | Berkeley Graduate Division')
              it ("shows delegate UID #{uid} a link to 'Graduate Division Degree Deadlines'") { expect(grad_div_calendar_link).to be true }

              calparents_link = WebDriverUtils.verify_external_link(@driver, @toolbox_page.cal_parents_element, 'Cal Parents')
              it ("shows delegate UID #{uid} a link to 'CalParents'") { expect(calparents_link).to be true }

              important_dates_link = WebDriverUtils.verify_external_link(@driver, @toolbox_page.important_dates_element, 'UC Berkeley Events Calendar | Cal Parents')
              it ("shows delegate UID #{uid} a link to 'Important Dates for Parents'") { expect(important_dates_link).to be true }

              visiting_campus_link = WebDriverUtils.verify_external_link(@driver, @toolbox_page.visiting_campus_element, 'Visitor Services')
              it ("shows delegate UID #{uid} a link to 'Visiting the Campus'") { expect(visiting_campus_link).to be true }

              jobs_and_careers_link = WebDriverUtils.verify_external_link(@driver, @toolbox_page.jobs_and_careers_element, 'Job Listing Sites | Career Center')
              it ("shows delegate UID #{uid} a link to 'Jobs & Careers'") { expect(jobs_and_careers_link).to be true }

              housing_link = WebDriverUtils.verify_external_link(@driver, @toolbox_page.housing_element, 'Housing & dining | University of California, Berkeley')
              it ("shows delegate UID #{uid} a link to 'Housing'") { expect(housing_link).to be true }

              financial_info_link = WebDriverUtils.verify_external_link(@driver, @toolbox_page.financial_info_element, 'Cost of Attendance | Financial Aid and Scholarships | UC Berkeley')
              it ("shows delegate UID #{uid} a link to 'Financial Information'") { expect(financial_info_link).to be true }

              academics_link = WebDriverUtils.verify_external_link(@driver, @toolbox_page.academics_element, 'Schools & colleges | University of California, Berkeley')
              it ("shows delegate UID #{uid} a link to 'Academics'") { expect(academics_link).to be true }

              academic_calendar_link = WebDriverUtils.verify_external_link(@driver, @toolbox_page.academic_calendar_element, 'Calendar | Office of the Registrar')
              it ("shows delegate UID #{uid} a link to 'Academic Calendar'") { expect(academic_calendar_link).to be true }

              newscenter_link = WebDriverUtils.verify_external_link(@driver, @toolbox_page.news_center_element, 'Berkeley News | News from the University of California, Berkeley')
              it ("shows delegate UID #{uid} a link to 'UC Berkeley NewsCenter'") { expect(newscenter_link).to be true }

              berkeley_news_link = WebDriverUtils.verify_external_link(@driver, @toolbox_page.berkeley_news_element, 'UC Berkeley - In the News')
              it ("shows delegate UID #{uid} a link to 'Berkeley in the News'") { expect(berkeley_news_link).to be true }

              daily_cal_link = WebDriverUtils.verify_external_link(@driver, @toolbox_page.daily_cal_element, 'The Daily Californian | Berkeley\'s News')
              it ("shows delegate UID #{uid} a link to 'The Daily Californian'") { expect(daily_cal_link).to be true }

            end

            # DELEGATE VIEW-AS EXPERIENCE

            students.each do |student|
              student_uid = student['uid']
              student_name = student['fullName']
              privileges = student['privileges']

              is_student = nil
              is_faculty = nil
              is_staff = nil

              begin

                # Log in as student to obtain unfiltered data

                @splash_page.load_page
                @splash_page.delegate_stop_viewing

                @splash_page.basic_auth student_uid
                @academics_api.get_json @driver
                @status_api.get_json @driver
                @financials_api.get_json @driver
                @cs_fin_aid_years_api.get_json @driver

                is_student = @status_api.is_student?
                is_faculty = @status_api.is_faculty?
                is_staff = @status_api.is_staff?

                test_output_row = [uid, student_uid, is_student, is_faculty, is_staff, privileges['viewEnrollments'],
                                   privileges['viewGrades'], privileges['financial'], privileges['phone']]
                UserUtils.add_csv_row(test_output, test_output_row)

                # Log in as delegate to check filtered data

                @splash_page.load_page
                @splash_page.basic_auth uid
                @toolbox_page.load_page
                logger.info "Delegate UID #{uid} is viewing as student UID #{student_uid} with privileges #{privileges}"

                if !privileges['phone'] && !privileges['viewEnrollments'] && !privileges['viewGrades'] && !privileges['financial']

                  view_as_button = @toolbox_page.delegator_link student_name
                  it ("shows delegate UID #{uid} no view-as button for UID #{student_uid}") { expect(view_as_button).to be nil }

                  if students.length == 1
                    shows_no_students_msg = @toolbox_page.no_students_msg?
                    it ("shows delegate UID #{uid} a 'you have no students' message for UID #{student_uid}") { expect(shows_no_students_msg).to be true }
                  end

                else

                  @toolbox_page.delegate_view_as student_name

                  current_url = @driver.current_url
                  if (privileges['viewEnrollments'] || privileges['viewGrades']) && @status_api.has_academics_tab?
                    it "lands delegate UID #{uid} on the Academics page for UID #{student_uid}" do
                      expect(current_url).to eql("#{WebDriverUtils.base_url}/academics")
                    end

                    @academic_profile_card.load_page
                    @academic_profile_card.profile_card_element.when_visible timeout

                    # Profile - name
                    shows_profile_name = @academic_profile_card.name?
                    it ("shows delegate UID #{uid} the academic profile name for UID #{student_uid}") { expect(shows_profile_name).to be true }

                    # Profile - career
                    unless @academics_api.has_no_standing?
                      shows_career = @academic_profile_card.all_careers.any?
                      it ("shows delegate UID #{uid} the academic career for UID #{student_uid}") { expect(shows_career).to be true }
                    end

                    # Profile - GPA
                    shows_gpa = @academic_profile_card.gpa?
                    if @academics_api.gpa.nil? || %w(0.0 0).include?(@academics_api.gpa) || !privileges['viewGrades']
                      it ("shows delegate UID #{uid} no GPA for UID #{student_uid}") { expect(shows_gpa).to be false }
                    else
                      it ("shows delegate UID #{uid} the GPA for UID #{student_uid}") { expect(shows_gpa).to be true }
                    end

                    # Reg Status
                    shows_reg_status = @status_card.status_holds_section?
                    it ("shows delegate UID #{uid} no registration status for UID #{student_uid}") { expect(shows_reg_status).to be false }

                    # Holds
                    shows_holds = @status_card.active_holds_table?
                    it ("shows delegate UID #{uid} no holds for UID #{student_uid}") { expect(shows_holds).to be false }

                    # Final Exams
                    shows_exams = @final_exams_card.final_exams_card_heading?
                    it ("shows delegate UID #{uid} no final exams for UID #{student_uid}") { expect(shows_exams).to be false }

                    # My Academics student semester cards

                    student_semesters = @academics_api.all_student_semesters
                    if student_semesters.any?

                      api_semesters = @academics_api.all_student_semesters

                      @semester_card.show_more if @semester_card.show_more_element.visible?
                      ui_semesters_count = @semester_card.semester_card_elements.length

                      it ("shows delegate UID #{uid} all the semester cards for UID #{student_uid}") { expect(ui_semesters_count).to eql(api_semesters.length) }

                      api_semesters.each do |semester|
                        @semester_card.load_page
                        @semester_card.page_heading_element.when_visible timeout
                        @semester_card.show_more if @semester_card.show_more_element.visible?

                        semester_name = @academics_api.semester_name semester
                        semester_courses = @academics_api.semester_courses(semester)

                        if @academics_api.past_semesters(api_semesters).include? semester

                          # Grades
                          ui_grades = @semester_card.grades(@driver, semester_name)
                          api_grades = @academics_api.semester_card_grades(api_semesters, semester_courses, semester).reject { |grade| grade.empty? }

                          if privileges['viewGrades']
                            it "shows delegate UID #{uid} the #{semester_name} grades on My Academics for UID #{student_uid}" do
                              expect(ui_grades.any?).to be true
                              expect(ui_grades).to eql(api_grades)
                            end
                          else
                            it "shows delegate UID #{uid} no #{semester_name} grades on My Academics for UID #{student_uid}" do
                              expect(ui_grades.any?).to be false
                            end
                          end
                        end

                        # Student semester pages

                        if @academics_api.has_enrollment_data? semester

                          semester_slug = @academics_api.semester_slug semester

                          blocks_semester_page = WebDriverUtils.verify_block do
                            @semester_card.load_semester_page semester_slug
                            @semester_card.not_found_element.when_present timeout
                          end
                          it ("prevents UID #{uid} from viewing the #{semester_name} semester page for UID #{student_uid}") { expect(blocks_semester_page).to be true }

                          blocks_booklist = WebDriverUtils.verify_block do
                            @booklist_page.load_page semester_slug
                            @booklist_page.not_found_element.when_present timeout
                          end
                          it ("prevents UID #{uid} from viewing the #{semester_name} book list page for UID #{student_uid}") { expect(blocks_booklist).to be true }

                          # Student class pages

                          semester_courses.each do |course|

                            class_page_url = @academics_api.course_url course
                            blocks_class_page = WebDriverUtils.verify_block do
                              @semester_card.load_class_page class_page_url
                              @semester_card.not_found_element.when_present timeout
                            end
                            it ("prevents UID #{uid} from viewing the #{class_page_url} class page for UID #{student_uid}") { expect(blocks_class_page).to be true }

                          end
                        end
                      end
                    end

                    # My Academics teaching semester cards

                    shows_teaching_card = @teaching_card.course_code_elements.any?
                    it ("shows delegate UID #{uid} no teaching card for UID #{student_uid}") { expect(shows_teaching_card).to be false }

                    teaching_semesters = @academics_api.all_teaching_semesters

                    unless teaching_semesters.nil?

                      teaching_semesters.each do |teaching_semester|

                        semester_name = @academics_api.semester_name teaching_semester
                        semester_slug = @academics_api.semester_slug teaching_semester

                        blocks_semester_page = WebDriverUtils.verify_block do
                          @classes_card.load_semester_page semester_slug
                          @classes_card.not_found_element.when_present timeout
                        end
                        it ("prevents UID #{uid} from viewing the #{semester_name} teaching page for UID #{student_uid}") { expect(blocks_semester_page).to be true }

                      end
                    end

                    @academic_profile_card.click_my_finances_link if privileges['finances']

                  elsif privileges['financial']

                    it ("lands delegate UID #{uid} with 'finances-only' privileges on the Finances page") { expect(current_url).to eql("#{WebDriverUtils.base_url}/finances") }

                  end

                  if privileges['financial']

                    @finances_page.load_page

                    # Financial Resources links
                    shows_fin_resources = @finances_page.fin_resources_list_element.when_visible timeout
                    it ("shows delegate UID #{uid} Financial Resources link for UID #{student_uid}") { expect(shows_fin_resources).to be_truthy }

                    # Financial Aid (CS)
                    @finances_page.finaid_content_element.when_visible timeout
                    if @cs_fin_aid_years_api.fin_aid_years.blank?

                      shows_no_aid_msg = @finances_page.no_finaid_message?
                      it ("shows delegate UID #{uid} a 'no FinAid' message for UID #{student_uid}") { expect(shows_no_aid_msg).to be true }

                    else

                      api_aid_years = @cs_fin_aid_years_api.fin_aid_years
                      (api_aid_years.length == 1) ?
                          shows_aid_years = @finances_page.finaid_single_year? :
                          shows_aid_years = @finances_page.finaid_multi_year_select?
                      it ("shows delegate UID #{uid} Financial Aid aid years for UID #{student_uid}") { expect(shows_aid_years).to be true }

                      api_aid_years.each do |year|

                        if @cs_fin_aid_years_api.t_and_c_approval year
                          @finances_fin_aid_page.load_fin_aid_profile @cs_fin_aid_years_api.fin_aid_year_id(year)
                          @finances_fin_aid_page.show_profile

                          shows_efc = @finances_fin_aid_page.efc?
                          it ("shows delegate UID #{uid} no expected family contribution for UID #{student_uid}") { expect(shows_efc).to be false }

                          shows_berkeley_parent_contrib = @finances_fin_aid_page.berkeley_parent_contrib?
                          it ("shows delegate UID #{uid} no Berkeley Parent Contribution for UID #{student_uid}") { expect(shows_berkeley_parent_contrib).to be false }

                        end
                      end
                    end

                    # Billing - Detail

                    if @financials_api.has_cars_data?
                      shows_details_summary = WebDriverUtils.verify_block do
                        @finances_details_page.load_page
                        @finances_details_page.account_bal_element.when_visible timeout
                      end
                      it ("shows delegate UID #{uid} the billing summary on the Details page for UID #{student_uid}") { expect(shows_details_summary).to be true }

                      WebDriverUtils.wait_for_element_and_select(@finances_details_page.activity_filter_select_element, 'All Transactions')
                      shows_transactions = @finances_details_page.transaction_table?
                      it ("shows delegate UID #{uid} the list of transactions on the Details page for UID #{student_uid}") { expect(shows_transactions).to be true }
                    end

                  else

                    # My Finances - hidden

                    shows_finances_link = @finances_page.my_finances_link?
                    it ("shows delegate UID #{uid} no My Finances link for UID #{student_uid}") { expect(shows_finances_link).to be false }

                    blocks_finances = WebDriverUtils.verify_block do
                      @finances_page.load_page
                      @finances_page.not_found_element.when_present timeout
                    end
                    it ("prevents delegate UID #{uid} from hitting the Finances page for UID #{student_uid} directly") { expect(blocks_finances).to be true }

                  end

                  # My Dashboard - always hidden

                  shows_dashboard_link = @finances_page.my_dashboard_link?
                  it ("shows delegate UID #{uid} no My Dashboard link for UID #{student_uid}") { expect(shows_dashboard_link).to be false }

                  blocks_dashboard = WebDriverUtils.verify_block do
                    @dashboard_page.load_page
                    @dashboard_page.not_found_element.when_present timeout
                  end
                  it ("prevents delegate UID #{uid} from hitting the Dashboard for UID #{student_uid} directly") { expect(blocks_dashboard).to be true }

                  # My Campus - always visible

                  sees_campus_links = WebDriverUtils.verify_block do
                    @campus_page.load_page
                    @campus_page.links_list_element.when_visible timeout
                  end
                  it ("shows delegate UID #{uid} My Campus links for UID #{student_uid}") { expect(sees_campus_links).to be true }

                  # bConnected badges - always hidden

                  shows_bmail = @campus_page.email_badge?
                  it ("shows delegate UID #{uid} no bConnected email for UID #{student_uid}") { expect(shows_bmail).to be false }

                  shows_bcal = @campus_page.calendar_badge?
                  it ("shows delegate UID #{uid} no bConnected invites for UID #{student_uid}") { expect(shows_bcal).to be false }

                  shows_bdrive = @campus_page.drive_badge?
                  it ("shows delegate UID #{uid} no bConnected documents for UID #{student_uid}") { expect(shows_bdrive).to be false }

                  # Profile - always hidden

                  shows_profile_popover = @campus_page.profile_icon?
                  it ("shows delegate UID #{uid} the Profile popover for UID #{student_uid}") { expect(shows_profile_popover).to be true }

                  shows_profile_link = @campus_page.profile_link?
                  it ("shows delegate UID #{uid} no Profile link for UID #{student_uid}") { expect(shows_profile_link).to be false }

                  blocks_basic_info = WebDriverUtils.verify_block do
                    @profile_basic.load_page
                    @profile_basic.not_found_element.when_present timeout
                  end
                  it ("prevents delegate UID #{uid} from hitting the Profile basic info page for UID #{student_uid}") { expect(blocks_basic_info).to be true }

                  blocks_contact_info = WebDriverUtils.verify_block do
                    @profile_contact.load_page
                    @profile_contact.not_found_element.when_present timeout
                  end
                  it ("prevents delegate UID #{uid} from hitting the Profile contact info page for UID #{student_uid}") { expect(blocks_contact_info).to be true }

                  blocks_demographics = WebDriverUtils.verify_block do
                    @profile_demographic.load_page
                    @profile_demographic.not_found_element.when_present timeout
                  end
                  it ("prevents delegate UID #{uid} from hitting the Profile demographic info page for UID #{student_uid}") { expect(blocks_demographics).to be true }

                  blocks_delegate_access = WebDriverUtils.verify_block do
                    @profile_delegate.load_page
                    @profile_delegate.not_found_element.when_present timeout
                  end
                  it ("prevents delegate UID #{uid} from hitting the Profile delegate access page for UID #{student_uid}") { expect(blocks_delegate_access).to be true }

                  blocks_disclosure = WebDriverUtils.verify_block do
                    @profile_disclosure.load_page
                    @profile_disclosure.not_found_element.when_present timeout
                  end
                  it ("prevents delegate UID #{uid} from hitting the Profile info disclosure page for UID #{student_uid}") { expect(blocks_disclosure).to be true }

                  blocks_title_iv = WebDriverUtils.verify_block do
                    @profile_title_iv.load_page
                    @profile_title_iv.not_found_element.when_present timeout
                  end
                  it ("prevents delegate UID #{uid} from hitting the Profile Title IV page for UID #{student_uid}") { expect(blocks_title_iv).to be true }

                  blocks_bconnected = WebDriverUtils.verify_block do
                    @profile_bconnected.load_page
                    @profile_bconnected.not_found_element.when_present timeout
                  end
                  it ("prevents delegate UID #{uid} from hitting the Profile bConnected page for UID #{student_uid}") { expect(blocks_bconnected).to be true }

                  # Toolbox - always hidden

                  blocks_student_toolbox = WebDriverUtils.verify_block do
                    @toolbox_page.load_page
                    @toolbox_page.not_found_element.when_present timeout
                  end
                  it ("prevents delegate UID #{uid} from hitting the student's Toolbox page for UID #{student_uid}") { expect(blocks_student_toolbox).to be true }

                  # Delegate Welcome

                  blocks_delegate = WebDriverUtils.verify_block do
                    @delegate_welcome.load_page
                    @delegate_welcome.not_found_element.when_present timeout
                  end
                  it ("prevents delegate UID #{uid} from hitting the delegate welcome page for UID #{student_uid}") { expect(blocks_delegate).to be true }

                  # OEC

                  blocks_oec = WebDriverUtils.verify_block do
                    @driver.get "#{WebDriverUtils.base_url}/oec"
                    wait.until { @driver.find_element(:xpath => '//h1[text()="Access Denied"]') }
                  end
                  it ("prevents UID #{uid} from reaching OEC for UID #{student_uid}") { expect(blocks_oec).to be true }

                  # CCAdmin

                  blocks_ccadmin = WebDriverUtils.verify_block do
                    @driver.get "#{WebDriverUtils.base_url}/ccadmin"
                    wait.until { @driver.find_element(:xpath => '//pre').text == ' ' }
                  end
                  it ("prevents UID #{uid} from reaching CCAdmin for UID #{student_uid}") { expect(blocks_ccadmin).to be true }

                  # TODO: Canvas

                end
              rescue => e
                logger.error e.message + "\n" + e.backtrace.join("\n")
              end
            end
          end
        rescue => e
          logger.error e.message + "\n" + e.backtrace.join("\n")
        end
      end
    rescue => e
      logger.error e.message + "\n" + e.backtrace.join("\n ")
    ensure
      WebDriverUtils.quit_browser(@driver)
    end
  end
end

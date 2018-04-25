describe 'My Dashboard My Classes card', :testui => true do

  if ENV["UI_TEST"] && Settings.ui_selenium.layer != 'production' && !Date.today.sunday?

    include ClassLogger

    begin

      driver = WebDriverUtils.launch_browser
      test_users = UserUtils.load_test_users
      testable_users = []
      faculty_links_tested = false
      test_output_heading = ['UID', 'Enrolled', 'Course Sites', 'Teaching', 'Teaching Sites', 'Other Sites']
      test_output = UserUtils.initialize_output_csv(self, test_output_heading)

      test_users.each do |user|
        if user['classes']
          uid = user['uid'].to_s
          logger.info("UID is #{uid}")
          has_enrollments = false
          has_course_sites = false
          has_teaching = false
          has_teaching_sites = false
          has_other_sites = false

          begin
            splash_page = CalCentralPages::SplashPage.new driver
            splash_page.load_page
            splash_page.basic_auth uid
            status_api = ApiMyStatusPage.new driver
            status_api.get_json driver
            academics_api = ApiMyAcademicsPageSemesters.new driver
            academics_api.get_json driver
            classes_api = ApiMyClassesPage.new driver
            classes_api.get_json driver
            my_classes = CalCentralPages::MyDashboardMyClassesCard.new driver
            my_classes.load_page
            my_classes.term_name_element.when_visible WebDriverUtils.academics_timeout
            term = my_classes.term_name.capitalize
            my_classes.enrolled_classes_div_element.when_present WebDriverUtils.page_event_timeout

            # ENROLLED CLASSES

            current_student_semester = academics_api.current_semester academics_api.all_student_semesters
            unless current_student_semester.nil?

              my_classes.enrolled_classes_div_element.when_visible WebDriverUtils.page_event_timeout

              current_semester_name = academics_api.semester_name current_student_semester
              it "shows the current term for student UID #{uid}" do
                expect(term).to eql(current_semester_name)
              end

              has_enrollments = true
              student_classes = academics_api.semester_courses(current_student_semester)

              # Courses listed once for each enrolled primary section
              api_student_course_ids = academics_api.semester_card_course_codes(academics_api.all_student_semesters, current_student_semester, student_classes)
              api_student_course_titles = academics_api.course_titles academics_api.courses_by_primary_section(student_classes)
              api_wait_list_prim_sections = academics_api.wait_list_primary_sections(student_classes)
              api_wait_list_positions = academics_api.wait_list_positions api_wait_list_prim_sections
              api_student_course_site_names = academics_api.semester_course_site_names student_classes
              api_student_course_site_desc = academics_api.semester_course_site_descrips student_classes

              my_classes_course_ids = my_classes.enrolled_course_codes
              my_classes_course_titles = my_classes.enrolled_course_titles
              my_classes_wait_list_positions = my_classes.wait_list_positions
              my_classes_course_site_names = my_classes.enrolled_course_site_names
              my_classes_course_site_desc = my_classes.enrolled_course_site_descrips

              has_course_sites = true if api_student_course_site_names.any?
              testable_users << uid if api_student_course_ids.any?

              it "shows the enrolled course ids for UID #{uid}" do
                expect(my_classes_course_ids).to eql(api_student_course_ids)
              end
              it "shows the enrolled course titles for UID #{uid}" do
                expect(my_classes_course_titles).to eql(api_student_course_titles)
              end
              it "shows the wait list positions for UID #{uid}" do
                expect(my_classes_wait_list_positions).to eql(api_wait_list_positions)
              end
              it "shows the enrolled course site names for UID #{uid}" do
                expect(my_classes_course_site_names).to eql(api_student_course_site_names)
              end
              it "shows the enrolled course site descriptions for UID #{uid}" do
                expect(my_classes_course_site_desc).to eql(api_student_course_site_desc)
              end

              # STUDENT CLASS PAGE LINKS

              student_classes.each do |course|

                api_course_title = academics_api.course_title(course)

                if academics_api.multiple_primaries?(course)
                  academics_api.course_primary_sections(course).each do |prim_section|
                    class_page_url = academics_api.section_url prim_section
                    my_classes.click_class_link_by_url class_page_url
                    class_page = CalCentralPages::MyAcademicsClassPage.new(driver)
                    class_page.class_info_heading_element.when_visible(WebDriverUtils.page_load_timeout)
                    class_page_course_title = class_page.course_title

                    it "offers a link to the class page for #{api_course_title} for UID #{uid}" do
                      expect(class_page_course_title).to eql(api_course_title)
                    end

                    my_classes.load_page
                  end

                else
                  class_page_url = academics_api.course_url(course)
                  my_classes.click_class_link_by_url class_page_url
                  class_page = CalCentralPages::MyAcademicsClassPage.new(driver)
                  class_page.class_info_heading_element.when_visible(WebDriverUtils.page_load_timeout)
                  class_page_course_title = class_page.course_title

                  it "offers a link to the class page for #{api_course_title} for UID #{uid}" do
                    expect(class_page_course_title).to eql(api_course_title)
                  end

                  my_classes.load_page
                end


              end
            end

            # TEACHING CLASSES

            current_teaching_semester = academics_api.current_semester academics_api.all_teaching_semesters
            unless current_teaching_semester.nil?

              my_classes.teaching_classes_div_element.when_visible WebDriverUtils.page_event_timeout

              current_semester_name = academics_api.semester_name current_teaching_semester
              it "shows the current term for teaching UID #{uid}" do
                expect(term).to eql(current_semester_name)
              end

              has_teaching = true
              teaching_classes = academics_api.semester_courses(current_teaching_semester)

              # All cross-listed course codes are shown; courses are listed once, regardless of multiple primaries
              api_teaching_course_ids = academics_api.semester_listing_course_codes current_teaching_semester
              api_teaching_course_titles = academics_api.course_titles teaching_classes
              api_teaching_course_site_names = academics_api.semester_course_site_names teaching_classes
              api_teaching_course_site_desc = academics_api.semester_course_site_descrips teaching_classes

              my_classes_teaching_course_ids = my_classes.teaching_course_codes
              my_classes_teaching_course_titles = my_classes.teaching_course_titles
              my_classes_teaching_site_names = my_classes.teaching_course_site_names
              my_classes_teaching_site_desc = my_classes.teaching_course_site_descrips

              has_teaching_sites = true if api_teaching_course_site_names.any?
              testable_users << uid if api_teaching_course_ids.any?

              it "shows the teaching course ids for UID #{uid}" do
                expect(my_classes_teaching_course_ids).to eql(api_teaching_course_ids)
              end
              it "shows the teaching course titles for UID #{uid}" do
                expect(my_classes_teaching_course_titles).to eql(api_teaching_course_titles)
              end
              it "shows the teaching course site names for UID #{uid}" do
                expect(my_classes_teaching_site_names).to eql(api_teaching_course_site_names)
              end
              it "shows the teaching course site descriptions for UID #{uid}" do
                expect(my_classes_teaching_site_desc).to eql(api_teaching_course_site_desc)
              end

              # TEACHING CLASS PAGE LINKS

              teaching_classes.each do |course|

                class_page_url = academics_api.course_url(course)
                my_classes.click_class_link_by_url class_page_url
                class_page = CalCentralPages::MyAcademicsClassPage.new(driver)
                class_page.class_info_heading_element.when_visible(WebDriverUtils.page_load_timeout)

                api_course_title = academics_api.course_title(course)
                class_page_course_title = class_page.course_title

                it "offers a link to the class page for #{api_course_title} for UID #{uid}" do
                  expect(class_page_course_title).to eql(api_course_title)
                end

                my_classes.load_page

              end
            end

            # OTHER SITES

            current_term = classes_api.current_term
            other_sites = academics_api.other_sites current_term
            if other_sites.any?

              my_classes.other_sites_div_element.when_visible WebDriverUtils.page_event_timeout

              has_other_sites = true

              api_other_site_names = academics_api.other_site_names other_sites
              api_other_site_desc = academics_api.other_site_descriptions other_sites

              my_classes_other_site_names = my_classes.other_course_site_names
              my_classes_other_site_desc = my_classes.other_course_site_descrips

              it "shows the 'other' course site names for UID #{uid}" do
                expect(my_classes_other_site_names).to eql(api_other_site_names)
              end
              it "shows the 'other' course site descriptions for UID #{uid}" do
                expect(my_classes_other_site_desc).to eql(api_other_site_desc)
              end
            end

            # HEADINGS DISPLAYED WITHIN THE CARD

            my_classes.wait_until(WebDriverUtils.page_event_timeout) do
              my_classes.enrollments_heading?
              my_classes.teaching_heading?
              my_classes.other_sites_heading?
            end

            has_student_heading = my_classes.enrollments_heading_element.visible?
            has_teaching_heading = my_classes.teaching_heading_element.visible?
            has_other_sites_heading = my_classes.other_sites_heading_element.visible?

            if has_enrollments && has_teaching
              it "shows an Enrollments heading for UID #{uid}" do
                expect(has_student_heading).to be true
              end
              it "shows a Teaching heading for UID #{uid}" do
                expect(has_teaching_heading).to be true
              end
            elsif has_enrollments && !has_teaching && has_other_sites
              it "shows an Enrollments heading for UID #{uid}" do
                expect(has_student_heading).to be true
              end
              it "shows no Teaching heading for UID #{uid}" do
                expect(has_teaching_heading).to be false
              end
            elsif !has_enrollments && has_teaching && has_other_sites
              it "shows no Enrollments heading for UID #{uid}" do
                expect(has_student_heading).to be false
              end
              it "shows a Teaching heading for UID #{uid}" do
                expect(has_teaching_heading).to be true
              end
            else
              it "shows no Enrollments heading for UID #{uid}" do
                expect(has_student_heading).to be false
              end
              it "shows no Teaching heading for UID #{uid}" do
                expect(has_teaching_heading).to be false
              end
            end

            if has_other_sites
              it "shows an Other Site Memberships heading for UID #{uid}" do
                expect(has_other_sites_heading).to be true
              end
            end

            # MESSAGING FOR USERS WITH NO CLASSES OR SITES

            has_not_enrolled_msg = my_classes.not_enrolled_msg?
            has_not_teaching_msg = my_classes.not_teaching_msg?
            has_not_enroll_not_teach_msg = my_classes.not_enrolled_not_teaching_msg?
            has_eap_msg = my_classes.eap_student_msg?
            has_registrar_link = my_classes.registrar_link?
            has_cal_student_central_link = my_classes.cal_student_central_link?

            if current_student_semester.nil? && current_teaching_semester.nil? && academics_api.other_sites(current_term).nil?

              # Student with no classes
              if status_api.is_student? && !status_api.is_faculty?
                registrar_link_works = WebDriverUtils.verify_external_link(driver, my_classes.registrar_link_element, 'Welcome to our web site - Office Of The Registrar')
                cal_student_central_link_works = WebDriverUtils.verify_external_link(driver, my_classes.cal_student_central_link_element, 'Welcome! | Cal Student Central')
                it "shows a 'not enrolled' message for UID #{uid}" do
                  expect(has_not_enrolled_msg).to be true
                end
                it "offers a valid link to the Registrar site for UID #{uid}" do
                  expect(registrar_link_works).to be true
                end
                it "offers a valid link to the Cal Student Central site for UID #{uid}" do
                  expect(cal_student_central_link_works).to be true
                end

              # Faculty with no teaching classes
              elsif status_api.is_faculty? && !status_api.is_student?
                it "shows a 'not teaching' message for UID #{uid}" do
                  expect(has_not_teaching_msg).to be true
                end
                it "offers no link to the Registrar site for UID #{uid}" do
                  expect(has_registrar_link).to be false
                end
                it "offers no link to the Cal Student Central site for UID #{uid}" do
                  expect(has_cal_student_central_link).to be false
                end

              # GSI with no student or teaching classes
              elsif status_api.is_student? && status_api.is_faculty?
                registrar_link_works = WebDriverUtils.verify_external_link(driver, my_classes.registrar_link_element, 'Welcome to our web site - Office Of The Registrar')
                cal_student_central_link_works = WebDriverUtils.verify_external_link(driver, my_classes.cal_student_central_link_element, 'Welcome! | Cal Student Central')
                it "shows a 'not enrolled and not teaching' message for UID #{uid}" do
                  expect(has_not_enroll_not_teach_msg).to be true
                end
                it "offers a valid link to the Registrar site for UID #{uid}" do
                  expect(registrar_link_works).to be true
                end
                it "offers a valid link to the Cal Student Central site for UID #{uid}" do
                  expect(cal_student_central_link_works).to be true
                end

              # Neither student nor faculty
              elsif !status_api.is_student? && !status_api.is_faculty?
                it "shows a 'not enrolled' message for UID #{uid}" do
                  expect(has_not_enrolled_msg).to be true
                end
                it "offers no link to the Registrar site for UID #{uid}" do
                  expect(has_registrar_link).to be false
                end
                it "offers no link to the Cal Student Central site for UID #{uid}" do
                  expect(has_cal_student_central_link).to be false
                end
              end
            end

            # FACULTY RESOURCES CARD

            faculty_resources = CalCentralPages::MyDashboardFacultyResourcesCard.new driver
            faculty_resources.load_page

            sched_classes_link = WebDriverUtils.verify_block { faculty_resources.schedule_of_classes_element.when_present WebDriverUtils.page_event_timeout }
            course_catalog_link = faculty_resources.course_catalog?
            assist_tech_link = faculty_resources.assistive_tech?
            bcourses_link = faculty_resources.bcourses?
            clickers_link = faculty_resources.clickers?
            course_capt_link = faculty_resources.course_capture?
            course_evals_link = faculty_resources.course_evals?
            diy_media_link = faculty_resources.diy_media?
            acad_innov_link = faculty_resources.acad_innov_studio?

            if status_api.is_faculty? || status_api.has_instructor_history?

              it ("offers a link to Schedule of Classes for UID #{uid}") { expect(sched_classes_link).to be true }
              it ("offers a link to Course Catalog for UID #{uid}") { expect(course_catalog_link).to be true }
              it ("offers a link to Assistive Technology for UID #{uid}") { expect(assist_tech_link).to be true }
              it ("offers a link to bCourses for UID #{uid}") { expect(bcourses_link).to be true }
              it ("offers a link to Clickers for UID #{uid}") { expect(clickers_link).to be true }
              it ("offers a link to Course Capture for UID #{uid}") { expect(course_capt_link).to be true }
              it ("offers a link to Course Evaluations for UID #{uid}") { expect(course_evals_link).to be true }
              it ("offers a link to DIY Media for UID #{uid}") { expect(diy_media_link).to be true }
              it ("offers a link to Academic Innovation Studio for UID #{uid}") { expect(acad_innov_link).to be true }

              unless faculty_links_tested

                sched_classes_link_works = WebDriverUtils.verify_external_link(driver, faculty_resources.schedule_of_classes_element, 'Home Page - Online Schedule Of Classes')
                it ("offers a valid link to Schedule of Classes for UID #{uid}") { expect(sched_classes_link_works).to be true }

                course_catalog_link_works = WebDriverUtils.verify_external_link(driver, faculty_resources.course_catalog_element, '2016-2017 Berkeley Academic Guide < University of California, Berkeley')
                it ("offers a valid link to Course Catalog for UID #{uid}") { expect(course_catalog_link_works).to be true }

                assist_tech_link_works = WebDriverUtils.verify_external_link(driver, faculty_resources.assistive_tech_element, 'Assistive Technology | Educational Technology Services')
                it ("offers a valid link to Assistive Technology for UID #{uid}") { expect(assist_tech_link_works).to be true }

                bcourses_link_works = WebDriverUtils.verify_external_link(driver, faculty_resources.bcourses_element, 'bCourses | Educational Technology Services')
                it ("offers a valid link to bCourses for UID #{uid}") { expect(bcourses_link_works).to be true }

                clickers_link_works = WebDriverUtils.verify_external_link(driver, faculty_resources.clickers_element, 'Clickers | Educational Technology Services')
                it ("offers a valid link to Clickers for UID #{uid}") { expect(clickers_link_works).to be true }

                course_capt_link_works = WebDriverUtils.verify_external_link(driver, faculty_resources.course_capture_element, 'Course Capture | Educational Technology Services')
                it ("offers a valid link to Course Capture for UID #{uid}") { expect(course_capt_link_works).to be true }

                course_evals_link_works = WebDriverUtils.verify_external_link(driver, faculty_resources.course_evals_element, 'Course Evaluations | Educational Technology Services')
                it ("offers a valid link to Course Evaluations for UID #{uid}") { expect(course_evals_link_works).to be true }

                diy_media_link_works = WebDriverUtils.verify_external_link(driver, faculty_resources.diy_media_element, 'DIY Media | Educational Technology Services')
                it ("offers a valid link to DIY Media for UID #{uid}") { expect(diy_media_link_works).to be true }

                acad_innov_link_works = WebDriverUtils.verify_external_link(driver, faculty_resources.acad_innov_studio_element, 'Academic Innovation Studio')
                it ("offers a valid link to Academic Innovation Studio for UID #{uid}") { expect(acad_innov_link_works).to be true }

                faculty_links_tested = true
              end

            else

              it ("offers no link to Schedule of Classes for UID #{uid}") { expect(sched_classes_link).to be false }
              it ("offers no link to Course Catalog for UID #{uid}") { expect(course_catalog_link).to be false }
              it ("offers no link to Assistive Technology for UID #{uid}") { expect(assist_tech_link).to be false }
              it ("offers no link to bCourses for UID #{uid}") { expect(bcourses_link).to be false }
              it ("offers no link to Clickers for UID #{uid}") { expect(clickers_link).to be false }
              it ("offers no link to Course Capture for UID #{uid}") { expect(course_capt_link).to be false }
              it ("offers no link to Course Evaluations for UID #{uid}") { expect(course_evals_link).to be false }
              it ("offers no link to DIY Media for UID #{uid}") { expect(diy_media_link).to be false }
              it ("offers no link to Academic Innovation Studio for UID #{uid}") { expect(acad_innov_link).to be false }

            end

          rescue => e
            logger.error e.message + "\n" + e.backtrace.join("\n")
          ensure
            test_output_row = [uid, has_enrollments, has_course_sites, has_teaching, has_teaching_sites, has_other_sites]
            UserUtils.add_csv_row(test_output, test_output_row)
          end
        end
      end
      it 'has student or teaching classes for at least one of the test users' do
        expect(testable_users.any?).to be true
      end
      it 'has Faculty Resources links for at least one of the test users' do
        expect(faculty_links_tested).to be true
      end
    rescue => e
      logger.error e.message + "\n" + e.backtrace.join("\n ")
    ensure
      WebDriverUtils.quit_browser(driver)
    end
  end
end

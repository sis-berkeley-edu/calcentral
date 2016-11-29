describe 'bCourses course site creation', :testui => true do

  if ENV["UI_TEST"] && Settings.ui_selenium.layer == 'local'

    include ClassLogger

    begin
      @driver = WebDriverUtils.launch_browser
      test_output = UserUtils.initialize_output_csv(self, ['Term', 'Course Code', 'Instructor', 'Site ID', 'Site Abbrev'])

      @splash_page = CalCentralPages::SplashPage.new @driver
      @cal_net_page = CalNetAuthPage.new @driver
      @status_api = ApiMyStatusPage.new @driver
      @academics_api = ApiMyAcademicsPage.new @driver
      @site_creation_page = CalCentralPages::CanvasSiteCreationPage.new @driver
      @create_course_site_page = CalCentralPages::CanvasCreateCourseSitePage.new @driver
      @canvas_page = CanvasPage.new @driver

      links_tested = false

      @canvas_page.log_in(@cal_net_page, UserUtils.canvas_username, UserUtils.canvas_password)

      test_courses = UserUtils.load_canvas_courses
      test_courses.each do |course|

        begin
          course_term = course['term']
          course_code = course['courseCode']
          course_title = course['courseTitle']
          instruction_formats = course['sectionFormatsForSite'].map { |format| format['label'] }
          instructor = course['teachers'].find { |teacher| teacher['testUser'] }
          site_id = nil
          site_abbreviation = nil

          logger.info "Creating a course site for #{course_code} in #{course_term} using the '#{course['workflow']}' workflow"

          @site_creation_page.choose_course_site(@driver, course, instructor, @canvas_page, @create_course_site_page)
          @create_course_site_page.search_for_course(course, instructor)

          unless links_tested

            @create_course_site_page.maintenance_button_element.when_visible WebDriverUtils.page_event_timeout
            short_maintenance_notice = @create_course_site_page.maintenance_button_element.text
            it ('shows a collapsed maintenance notice') { expect(short_maintenance_notice).to include('From 8 - 9 AM, you may experience delays of up to 10 minutes') }

            @create_course_site_page.maintenance_button

            long_maintenance_notice = @create_course_site_page.maintenance_notice_element.text
            it ('shows an expanded maintenance notice') { expect(long_maintenance_notice).to include('bCourses performs scheduled maintenance every day between 8-9AM') }

            bcourses_link = WebDriverUtils.verify_external_link(@driver, @create_course_site_page.bcourses_service_element, 'bCourses | Educational Technology Services')
            it ('shows a link to the bCourses service page') { expect(bcourses_link).to be true }

            @canvas_page.switch_to_frame @driver
            @create_course_site_page.click_need_help @driver

            help_text = @create_course_site_page.help_element.text
            it ('shows suggestions for creating sites for courses with multiple sections') { expect(help_text).to include('If you have a course with multiple sections, you will need to decide') }

            links_tested = true

          end

          @create_course_site_page.toggle_course_sections course

          expected_section_ids = course['sections'].map { |section| section['ccn'] }
          visible_section_ids = @create_course_site_page.course_section_ids(@driver, course_code)
          it ("offers all the expected sections for #{course_term} #{course_code}") { expect(visible_section_ids.sort!).to eql(expected_section_ids.sort!) }

          filtered_section_data = @create_course_site_page.sections_by_formats(@driver, course, instruction_formats)
          @create_course_site_page.select_sections filtered_section_data
          @create_course_site_page.click_next

          default_name = @create_course_site_page.site_name_input
          it ("shows the default site name #{course['courseTitle']}") { expect(default_name).to eql(course_title) }

          default_abbreviation = @create_course_site_page.site_abbreviation
          it ("shows the default site abbreviation #{course['courseCode']}") { expect(default_abbreviation).to include(course_code) }

          site_abbreviation = @create_course_site_page.enter_site_titles course_code
          logger.info "Course site abbreviation will be #{site_abbreviation}"

          @create_course_site_page.click_create_site

          site_created = WebDriverUtils.verify_block do
            @canvas_page.wait_until(WebDriverUtils.canvas_update_timeout) { @canvas_page.current_url.include? "#{WebDriverUtils.canvas_base_url}/courses" }
          end
          it ("redirects to the #{course_term} #{course_code} course site in Canvas when finished") { expect(site_created).to be true }

          site_id = @canvas_page.current_url.delete "#{WebDriverUtils.canvas_base_url}/courses/"
          logger.info "Canvas course site ID is #{site_id}"

        rescue => e
          logger.error e.message + "\n" + e.backtrace.join("\n")
        ensure
          UserUtils.add_csv_row(test_output, [course_term, course_code, instructor['uid'], site_id, site_abbreviation])
        end
      end
    rescue => e
      logger.error e.message + "\n" + e.backtrace.join("\n")
    ensure
      WebDriverUtils.quit_browser @driver
    end
  end
end

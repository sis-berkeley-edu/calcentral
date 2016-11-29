module CalCentralPages

  class CanvasCreateCourseSitePage

    include PageObject
    include CalCentralPages
    include ClassLogger

    h1(:page_heading, :xpath => '//h1[text()="Create a Course Site"]')

    button(:maintenance_button, :class => 'bc-template-canvas-maintenance-notice-button')
    div(:maintenance_notice, :class => 'bc-template-canvas-maintenance-notice-details')
    link(:bcourses_service, :xpath => '//a[contains(text(),"bCourses service page")]')
    button(:need_help, :xpath => '//button[contains(.,"Need help deciding which official sections to select")]')
    div(:help, :id => 'section-selection-help')

    button(:switch_mode, :class => 'bc-page-create-course-site-admin-mode-switch')

    span(:switch_to_instructor, :xpath => '//span[contains(.,"Switch to acting as instructor")]')
    button(:as_instructor_button, :xpath => '//button[text()="As instructor"]')
    text_area(:instructor_uid, :id => 'instructor-uid')

    span(:switch_to_ccn, :xpath => '//span[contains(.,"Switch to CCN input")]')
    button(:review_ccns_button, :xpath => '//button[text()="Review matching CCNs"]')
    text_area(:ccn_list, :id => 'bc-page-create-course-site-ccn-list')

    button(:next_button, :xpath => '//button[text()="Next"]')
    link(:cancel_link, :text => 'Cancel')

    text_area(:site_name_input, :id => 'siteName')
    text_area(:site_abbreviation, :id => 'siteAbbreviation')

    button(:create_site_button, :xpath => '//button[text()="Create Course Site"]')
    button(:go_back_button, :xpath => '//button[text()="Go Back"]')

    def load_page
      navigate_to "#{WebDriverUtils.base_url}/canvas/embedded/create_course_site"
      page_heading_element.when_visible WebDriverUtils.page_load_timeout
    end

    def choose_term(course)
      button_element(:xpath => "//label[contains(.,'#{course['term']}')]/preceding-sibling::input").when_visible WebDriverUtils.page_event_timeout
      click_element_js button_element(:xpath => "//label[contains(.,'#{course['term']}')]/preceding-sibling::input")
    end

    def search_for_course(course, instructor)
      logger.debug "Searching for #{course['courseCode']} in #{course['term']}"
      create_site_workflow = course['workflow']
      if create_site_workflow == 'uid'
        uid = instructor['uid']
        logger.debug "Searching by instructor UID #{uid}"
        switch_mode unless switch_to_ccn?
        WebDriverUtils.wait_for_element_and_type(instructor_uid_element, uid)
        WebDriverUtils.wait_for_element_and_click as_instructor_button_element
        choose_term course
      elsif create_site_workflow == 'ccn'
        logger.debug 'Searching by CCN list'
        switch_mode unless switch_to_instructor?
        choose_term course
        sleep 1
        ccn_list = course['sections'].map { |section| section['ccn'] }
        logger.debug "CCN list is '#{ccn_list}'"
        WebDriverUtils.wait_for_element_and_type(ccn_list_element, ccn_list.join(', '))
        click_element_js review_ccns_button_element
      else
        logger.debug 'Searching as the instructor'
        choose_term course
      end
    end

    def click_need_help(driver)
      driver.find_element(xpath: '//button[contains(.,"Need help deciding which official sections to select")]').click
    end

    def course_toggle(course)
      button_element(:xpath => "//button[contains(@aria-label,'#{course['courseTitle']}')]")
    end

    def toggle_course_sections(course)
      WebDriverUtils.wait_for_element_and_click course_toggle(course)
    end

    # Section rows on page

    def section_data(driver, section_id)
      {
          :code => section_course_code(section_id),
          :label => section_label(section_id),
          :id => section_id(driver, section_id),
          :schedules => section_schedules(driver, section_id),
          :locations => section_locations(driver, section_id),
          :instructors => section_instructors(driver, section_id)
      }
    end

    def course_data(driver, course)
      course_section_ids(driver, course['courseCode']).map { |section_id| section_data(driver, section_id) }
    end

    def sections_by_formats(driver, course, section_formats)
      course_data(driver, course).select do |section|
        section_formats.include? section[:label][0,3]
      end
    end

    def select_sections(sections)
      section_labels = sections.map { |section| section[:label] }
      logger.debug "Selecting sections #{section_labels * ', '}"
      sections.each do |section|
        section_checkbox(section[:id]).check
      end
    end

    def section_checkbox(section_id)
      checkbox_element(:xpath => "//input[contains(@id,'#{section_id}')]")
    end

    def section_course_code(section_id)
      span_element(:xpath => "//input[contains(@id,'#{section_id}')]/ancestor::tbody//td[contains(@class, 'course-code')]/span").text
    end

    def section_label(section_id)
      label_element(:xpath => "//label[@for='cc-template-canvas-manage-sections-checkbox-#{section_id}']").text
    end

    def section_id(driver, section_id)
      driver.find_element(:xpath => "//input[contains(@id,'#{section_id}')]/ancestor::tbody//td[@data-ng-bind='section.ccn']").text
    end

    def section_schedules(driver, section_id)
      schedule_elements = driver.find_elements(:xpath => "//input[contains(@id,'#{section_id}')]/../ancestor::tbody//td[contains(@class, 'section-timestamps')]/div")
      schedule_elements.map &:text
    end

    def section_locations(driver, section_id)
      location_elements = driver.find_elements(:xpath => "//input[contains(@id,'#{section_id}')]/../ancestor::tbody//td[contains(@class, 'section-locations')]/div")
      location_elements.map &:text
    end

    def section_instructors(driver, section_id)
      instructor_elements = driver.find_elements(:xpath => "//input[contains(@id,'#{section_id}')]/../ancestor::tbody//td[contains(@class, 'section-instructors')]/div")
      instructor_elements.map &:text
    end

    def course_section_ids(driver, course_code)
      driver.find_elements(:xpath => "//button[contains(.,'#{course_code}')]/following-sibling::div//td[@data-ng-bind='section.ccn']").map &:text
    end

    def click_next
      wait_until(WebDriverUtils.page_event_timeout) { !next_button_element.attribute('disabled') }
      next_button
      site_name_input_element.when_visible WebDriverUtils.page_load_timeout
    end

    def enter_site_titles(course_code)
      site_abbreviation = "QA TEST #{Time.now.to_i.to_s}"
      WebDriverUtils.wait_for_element_and_type(site_name_input_element, "#{site_abbreviation} - #{course_code}")
      WebDriverUtils.wait_for_element_and_type(site_abbreviation_element, site_abbreviation)
      site_abbreviation
    end

    def click_create_site
      WebDriverUtils.wait_for_element_and_click create_site_button_element
    end

  end
end

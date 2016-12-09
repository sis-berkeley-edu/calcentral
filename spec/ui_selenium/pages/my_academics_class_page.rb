module CalCentralPages

  class MyAcademicsClassPage < MyAcademicsPage

    include PageObject
    include CalCentralPages

    span(:class_breadcrumb, :xpath => '//h1/span[@data-ng-bind="selectedCourse.course_code"]')
    span(:section_breadcrumb, :xpath => '//h1/span[@data-ng-bind="selectedSection"]')

    # CLASS INFO
    h2(:class_info_heading, :xpath => '//h2[text()="Class Information"]')
    div(:course_title, :xpath => '//h3[text()="Class Title"]/following-sibling::div[@data-ng-bind="selectedCourse.title"]')
    div(:role, :xpath => '//h3[text()="My Role"]/following-sibling::div[@data-ng-bind="selectedCourse.role"]')
    elements(:teaching_section_label, :td, :xpath => '//td[@data-ng-bind="sec.section_label"]')
    elements(:student_section_label, :td, :xpath => '//h3[text()="My Enrollment"]/following-sibling::div[@data-ng-if="selectedCourse.sections.length && !isInstructorOrGsi"]//td[@data-ng-bind="sec.section_label"]')
    elements(:student_section_ccn, :td, :xpath => '//h3[text()="My Enrollment"]/following-sibling::div[@data-ng-if="selectedCourse.sections.length && !isInstructorOrGsi"]//td[@data-ng-bind="sec.ccn"]')
    elements(:section_units, :td, :xpath => '//h3[text()="Class Info"]/following-sibling::div[@data-ng-if="!isInstructorOrGsi"]//td[@data-ng-if="section.units"]')
    elements(:section_grade_option, :td, :xpath => '//h4[text()="Course Offering"]/following-sibling::div[@data-ng-if="!isInstructorOrGsi"]//td[@data-ng-bind="section.gradeOption"]')
    elements(:recurring_schedule_label, :div, :xpath => '//div[@data-ng-if="section.schedules.recurring.length"][@data-ng-bind="section.section_label"]')
    elements(:recurring_schedule, :div, :xpath => '//div[@data-ng-repeat="schedule in section.schedules.recurring"]')
    elements(:one_time_schedule_label, :div, :xpath => '//div[@data-ng-if="section.schedules.oneTime.length"][@data-ng-bind="section.section_label"]')
    elements(:one_time_schedule, :div, :xpath => '//div[@data-ng-repeat="schedule in section.schedules.oneTime"]')

    elements(:section_schedule_label, :div, :xpath => '//div[@data-ng-repeat="section in selectedCourse.sections"]/div[@data-ng-bind="section.section_label"]')
    elements(:student_section_schedule, :div, :xpath => '//h4[text()="Section Schedules"]/following-sibling::div[@data-ng-repeat="section in selectedCourse.sections"]//div[@data-ng-repeat="schedule in section.schedules"]')
    elements(:teaching_section_schedule, :div, :xpath => '//h3[text()="Section Schedules"]/following-sibling::div[@data-ng-repeat="section in selectedCourse.sections"]//div[@data-ng-repeat="schedule in section.schedules"]')
    h3(:cross_listing_heading, :xpath => '//h3[text()="Cross-listed As"]')
    elements(:cross_listing, :span, :xpath => '//span[@data-ng-bind="listing.course_code"]')

    # INSTRUCTORS
    elements(:section_instructors_heading, :h3, :xpath => '//h3[@data-ng-bind="section.section_label"]')

    # TEXTBOOKS
    h2(:textbooks_heading, :xpath => '//h2[text()="Textbooks"]')

    def all_teaching_section_labels
      teaching_section_label_elements.map &:text
    end

    def all_student_section_labels
      student_section_label_elements.map &:text
    end

    def all_student_section_ccns
      student_section_ccn_elements.map &:text
    end

    def all_section_units
      section_units_elements.map &:text
    end

    def all_section_grade_options
      section_grade_option_elements.map &:text
    end

    def all_recurring_schedule_labels
      recurring_schedule_label_elements.map &:text
    end

    def all_recurring_schedules
      recurring_schedule_elements.map &:text
    end

    def all_one_time_schedule_labels
      one_time_schedule_label_elements.map &:text
    end

    def all_one_time_schedules
      one_time_schedule_elements.map &:text
    end

    def all_teaching_section_schedules
      teaching_section_schedule_elements.map &:text
    end

    def all_section_instructors(driver, section_labels)
      instructors = []
      section_labels.each do |section|
        instructor_elements = driver.find_elements(:xpath => "//h3[text()='#{section}']/../../../following-sibling::tbody//a")
        instructor_elements.each { |instructor| instructors.push((instructor.text).gsub("\n- opens in new window", '')[2..-1]) }
      end
      instructors
    end

    def all_course_instructors(driver, sections)
      instructors = []
      sections.each do |section|
        instructors.push(all_section_instructors(driver, section))
      end
      instructors
    end

    def all_cross_listings
      cross_listing_elements.map &:text
    end

  end
end

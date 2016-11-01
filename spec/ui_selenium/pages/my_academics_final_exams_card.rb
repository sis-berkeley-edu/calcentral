module CalCentralPages

  class MyAcademicsFinalExamsCard < MyAcademicsPage

    include PageObject
    include CalCentralPages

    h2(:final_exams_card_heading, :xpath => '//h2[contains(.,"Final Exam Schedule")]')

    def disclaimer(driver, term_name)
      driver.find_element(:xpath => "//h3[text()='#{term_name}']/following-sibling::div[text()='Dates and times are subject to change. Please check your syllabus for the official exam day and time for each class.']")
    end

    def time_slots(term_name)
      div_elements(:xpath => "//h3[text()='#{term_name}']/following-sibling::div[contains(@data-ng-repeat,'exam_slot')]")
    end

    def exams_in_time_slot(term_name, time_slot_node)
      div_elements(:xpath => "//h3[text()='#{term_name}']/following-sibling::div[contains(@data-ng-repeat,'exam_slot')][#{time_slot_node}]//div[@data-ng-repeat='course in exam']")
    end

    def exam_date(term_name, time_slot_node, exam_node)
      element = span_element(:xpath => "//h3[text()='#{term_name}']/following-sibling::div[contains(@data-ng-repeat,'exam_slot')][#{time_slot_node}]//div[@data-ng-repeat='course in exam'][#{exam_node}]//span[@data-ng-bind='course.exam_date']")
      element && element.text
    end

    def exam_time(term_name, time_slot_node, exam_node)
      element = span_element(:xpath => "//h3[text()='#{term_name}']/following-sibling::div[contains(@data-ng-repeat,'exam_slot')][#{time_slot_node}]//div[@data-ng-repeat='course in exam'][#{exam_node}]//span[@data-ng-bind='course.exam_time']")
      element && element.text
    end

    def exam_course(term_name, time_slot_node, exam_node)
      element = div_element(:xpath => "//h3[text()='#{term_name}']/following-sibling::div[contains(@data-ng-repeat,'exam_slot')][#{time_slot_node}]//div[@data-ng-repeat='course in exam'][#{exam_node}]//strong[@data-ng-bind='course.name']")
      element && element.text
    end

    def exam_course_wait_list(term_name, time_slot_node, exam_node)
      element = div_element(:xpath => "//h3[text()='#{term_name}']/following-sibling::div[contains(@data-ng-repeat,'exam_slot')][#{time_slot_node}]//div[@data-ng-repeat='course in exam'][#{exam_node}]//span[@data-ng-if='course.waitlisted']")
      element.exists? ? element.text : nil
    end

    def exam_location(term_name, time_slot_node, exam_node)
      element = div_element(:xpath => "//h3[text()='#{term_name}']/following-sibling::div[contains(@data-ng-repeat,'exam_slot')][#{time_slot_node}]//div[@data-ng-repeat='course in exam'][#{exam_node}]//div[@data-ng-bind='course.exam_location']")
      element && element.text
    end

    def exam_conflict(term_name)
      div_elements(:xpath => "//h3[text()='#{term_name}']/following-sibling::div[contains(@data-ng-repeat,'exam_slot')]//strong[contains(.,'Exam Conflict')]")
    end

    def term_exams(term_name)
      # Collect the visible data from each exam listed in each time slot in the UI
      exams = []
      time_slots(term_name).each do |slot|
        # Get the time slot's node in the HTML
        time_slot_node = time_slots(term_name).index(slot) + 1
        exams_in_slot = exams_in_time_slot(term_name, time_slot_node)
        exams_in_slot.each do |exam|
          # Get the exam's node in the HTML
          exam_node = exams_in_slot.index(exam) + 1
          exam_schedule = []
          exam_schedule << term_name
          exam_schedule << exam_date(term_name, time_slot_node, exam_node)
          exam_schedule << exam_time(term_name, time_slot_node, exam_node)
          exam_course_wait_list(term_name, time_slot_node, exam_node).nil? ?
              exam_schedule << exam_course(term_name, time_slot_node, exam_node) :
              exam_schedule << (exam_course(term_name, time_slot_node, exam_node) + exam_course_wait_list(term_name, time_slot_node, exam_node))
          exam_schedule << exam_location(term_name, time_slot_node, exam_node)
          exams << exam_schedule
        end
      end
      exams
    end

  end
end

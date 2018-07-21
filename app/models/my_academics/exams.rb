module MyAcademics
  class Exams < UserSpecificModel

    def merge(data = {})
      if Settings.features.final_exam_schedule_student
        if semesters = data.try(:[], :semesters)
          parse_semesters(semesters)
        end
      end
      if Settings.features.final_exam_schedule_instructor
        if teaching_semesters = data.try(:[], :teachingSemesters)
          parse_semesters(teaching_semesters)
        end
      end
    end

    def parse_semesters(semesters)
      semesters.reject{|x| x[:termCode] == 'C' || x[:timeBucket] == 'past'}.each do |semester|
        semester_exam_schedule = get_semester_exam_schedule(semester)
        semester[:exams] = {
          schedule: HashConverter.camelize(semester_exam_schedule),
          courseCareerCodes: collect_semester_course_career_codes(semester)
        }
      end
    end

    def collect_semester_course_career_codes(semester)
      semester[:classes].collect do |course|
        has_primary_section = course[:sections].find { |s| s[:is_primary_section] }
        has_primary_section ? course[:courseCareerCode] : nil
      end.compact.uniq
    end

    def get_semester_exam_schedule(semester)
      semester_exams = collect_semester_exams(semester)
      merged_semester_exams = merge_course_timeslot_locations(semester_exams)
      flag_duplicate_semester_exam_courses(merged_semester_exams)
      flag_conflicting_timeslots(merged_semester_exams)
      sort_semester_exams(merged_semester_exams)
    end

    def sort_semester_exams(semester_exams)
      semester_exams.sort_by do |exam|
        (exam.try(:[], :exam_slot).try(:utc) || Time.now + 1000.years).to_s + ' ' + exam.try(:[], :name)
      end
    end

    def collect_semester_exams(semester)
      semester_final_exams = []
      semester[:classes].each do |course|
        if (course[:courseCareerCode] == 'UGRD')
          course[:sections].select{|sec| sec[:is_primary_section] }.each do |section|
            section_data = {
              name: course[:course_code],
              courseCareerCode: course[:courseCareerCode],
              section_label: section[:section_label],
              waitlisted: section[:waitlisted]
            }
            section_final_exams = get_section_final_exams(semester[:termId], section[:ccn])
            merged_section_final_exams = section_final_exams.collect {|exam| exam.merge(section_data)}
            if merged_section_final_exams.any?
              section_payload = merged_section_final_exams
            else
              section_payload = [
                section_data.merge({
                  exam_location: 'Exam information not available at this time.'
                })
              ]
            end
            semester_final_exams.concat(section_payload)
          end
        end
      end
      semester_final_exams
    end

    def get_section_final_exams(term_id, section_id)
      final_exams = EdoOracle::Queries.get_section_final_exams(term_id, section_id)
      unique_final_exams = final_exams.collect {|e| e.symbolize_keys }.uniq
      unique_final_exams.collect {|exam| parse_exam(exam) }.compact
    end

    def merge_course_timeslot_locations(semester_exams)
      merged_exams = []
      timeslot_course_grouped_exams = semester_exams.group_by do |e|
        "#{e.try(:[], :exam_slot).try(:strftime, '%m-%d-%Y %H:%M')}-#{e[:name]}-#{e[:section_label]}"
      end
      timeslot_course_grouped_exams.each do |slot, exams|
        locations = exams.collect {|e| e[:exam_location] }.compact.uniq
        merged_exam = exams.first
        merged_exam.delete(:exam_location)
        merged_exam[:exam_locations] = locations
        merged_exams << merged_exam
      end
      merged_exams
    end

    def flag_duplicate_semester_exam_courses(semester_exams)
      name_tracking_hash = {}
      semester_exams.each do |exam|
        name_tracking_hash[exam[:name]] ||= 0
        name_tracking_hash[exam[:name]] = name_tracking_hash[exam[:name]] + 1
      end
      semester_exams.each do |exam|
        exam[:display_section_label] = name_tracking_hash[exam[:name]] > 1
      end
    end

    def flag_conflicting_timeslots(semester_exams)
      slot_grouped_exams = semester_exams.group_by { |e| e[:exam_slot] }
      slot_grouped_exams.each do |slot, exams|
        exam_course_names = exams.collect {|e| "#{e[:name]}-#{e[:section_label]}" }.uniq
        slot_grouped_exams[slot].each do |exam|
          exam[:time_conflict] = (exam_course_names.count > 1) && is_datetime?(slot)
        end
      end
    end

    def is_datetime?(d)
      %w(Date Time DateTime Timezone).any? { |t| d.class.name == t }
    end

    # Applies logic based on translate value and pre/post finalization status
    def parse_exam(exam)
      if exam[:finalized] != 'Y' && exam[:exam_type] == 'L'
        return nil
      end
      {
        exam_location: choose_cs_exam_location(exam),
        exam_date: parse_cs_exam_date(exam),
        exam_time: parse_cs_exam_time(exam),
        exam_slot: parse_cs_exam_slot(exam),
        exception: exam[:exam_exception],
        finalized: exam[:finalized]
      }
    end

    # Takes the exam date and makes it presentable, Mon 12/12
    def parse_cs_exam_date(exam)
      if exam[:finalized] != 'Y'
        if exam[:exam_exception] == 'Y' || (exam[:exam_type] != 'Y' && exam[:exam_type] != 'C')
          return nil
        end
      end
      date = exam[:exam_date]
      date && date.strftime('%a %b %-d')
    end

    # Takes the exam time and makes it presentable, 07:00PM-10:00PM
    def parse_cs_exam_time(exam)
      if exam[:finalized] != 'Y'
        if exam[:exam_exception] == 'Y' || (exam[:exam_type] != 'Y' && exam[:exam_type] != 'C')
          return nil
        end
      end
      start = exam[:exam_start_time]
      ending = exam[:exam_end_time]
      if start && ending
        start_time = (start.strftime '%l:%M').strip
        start_time_meridian_indicator = single_letter_meridian_indicator(start.strftime '%p')
        end_time = (ending.strftime '%l:%M').strip
        end_time_meridian_indicator = single_letter_meridian_indicator(ending.strftime '%p')
        return "#{start_time}#{start_time_meridian_indicator} - #{end_time}#{end_time_meridian_indicator}"
      end
      nil
    end

    def single_letter_meridian_indicator(meridian_string)
      if meridian_string.downcase == 'pm'
        return 'P'
      elsif meridian_string.downcase == 'am'
        return 'A'
      else
        return ''
      end
    end

    # Takes exam information and makes it usable
    def parse_cs_exam_slot(exam)
      time = exam[:exam_start_time]
      date = exam[:exam_date]

      if exam[:finalized] != 'Y'
        if exam[:exam_exception] == 'Y'
          return 'none'
        else
          if exam[:exam_type] == 'N' || exam[:exam_type] == 'A'
            return 'none'
          end
        end
      end
      if time && date
        Time.parse("#{date.strftime '%y-%m-%d'} #{time.strftime '%H:%M'}")
      elsif date
        Time.parse(date.strftime '%y-%m-%d')
      else
        'none'
      end
    end

    def choose_cs_exam_location(exam)
      if exam[:location]
        if exam[:exam_exception] == 'Y'
          return 'Exam information not available at this time.'
        else
          if exam[:finalized] == 'Y'
            return exam.try(:[], :location)
          else
            if exam[:exam_type] == 'Y' || exam[:exam_type] == 'C'
              return 'Exam Location TBD'
            else
              return 'Exam information not available at this time.'
            end
          end
        end
      end
      nil
    end

  end
end

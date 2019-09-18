module MyAcademics
  class Semesters < UserSpecificModel
    include Concerns::AcademicsModule
    include Concerns::Careers

    def initialize(uid)
      super(uid)
      @campus_solutions_id = CalnetCrosswalk::ByUid.new(user_id: @uid).lookup_campus_solutions_id
    end

    def merge(data)
      if (@filtered = data[:filteredForDelegate])
        enrollments = EdoOracle::UserCourses::All.new(user_id: @uid).enrollments_summary
      else
        enrollments = EdoOracle::UserCourses::All.new(user_id: @uid).all_campus_courses
      end
      data[:semesters] = semester_feed(enrollments).compact
      merge_semesters_count data
    end

    def semester_feed(enrollment_terms)
      withdrawal_terms = withdrawal_data.map{|row| Berkeley::TermCodes.edo_id_to_code(row['term_id'])}
      study_prog_terms = study_prog_data.map{|row| Berkeley::TermCodes.edo_id_to_code(row['term_id'])}

      # Note: a student should never have withdrawal and absentia or filling fee for same term
      (enrollment_terms.keys | withdrawal_terms | study_prog_terms).sort.reverse.map do |term_key|
        semester = semester_info term_key
        semester[:filteredForDelegate] = !!@filtered
        if enrollment_terms[term_key]
          semester[:hasEnrollmentData] = true
          semester[:classes] = process_enrollments(enrollment_terms[term_key], semester[:termId])
          semester[:hasEnrolledClasses] = has_enrolled_classes?(enrollment_terms[term_key])
          merge_grades(semester)
          semester.merge! unit_totals(enrollment_terms[term_key])
        else
          merge_withdrawals(semester)
        end
        merge_study_prog(semester)
        merge_standings(semester)
        semester unless semester[:classes].empty? && !semester[:hasWithdrawalData] && !semester[:hasStudyProgData]
      end
    end

    def study_prog_data
      registration_status.select{|row| row['splstudyprog_type_code'].present?}
    end

    def withdrawal_data
      registration_status.select{|row| row['withcncl_type_code'].present?}
    end

    def registration_status
      @registration_status ||= begin
        EdoOracle::Queries.get_registration_status(@campus_solutions_id)
      end
    end

    def academic_careers
      @academic_careers ||= begin
        careers = EdoOracle::Career.new(user_id: @uid).fetch
        active_or_all_careers = Concerns::Careers.active_or_all(careers)
        active_or_all_careers.try(:map) {|career| career.try(:[], 'acad_career')}
      end
    end

    def unit_totals(enrollments = [])
      academic_careers = (enrollments.collect {|enrollment| enrollment[:academicCareer].try(:intern)}).uniq
      unit_totals = EdoOracle::CareerTerm.new(user_id: @uid).term_summary(academic_careers, enrollments.first.try(:[], :term_id))
      total_law_units = unit_totals[:grading_complete] ? unit_totals[:total_earned_law_units] : unit_totals[:total_enrolled_law_units]
      {
        totalUnits: unit_totals[:grading_complete] ? unit_totals[:total_earned_units] : unit_totals[:total_enrolled_units],
        totalLawUnits: law_student? || academic_careers.include?(:LAW) ? total_law_units : nil,
        isGradingComplete: unit_totals[:grading_complete]
      }
    end

    def merge_study_prog(semester)
      study_prog_data.each do |row|
        if row['term_id'] == Berkeley::TermCodes.slug_to_edo_id(semester[:slug])
          semester.merge! map_study_prog(row)
        end
      end
    end

    def map_study_prog(row)
      {
        hasStudyProgData: true,
        studyProg: {
          studyprogTypeCode: row['splstudyprog_type_code'],
          studyprogTypeDescr: row['splstudyprog_type_descr'],
        }
      }
    end

    def merge_withdrawals(semester)
      withdrawal_data.each do |row|
        if row['term_id'] == Berkeley::TermCodes.slug_to_edo_id(semester[:slug])
          withdrawal_status = map_withdrawal_status(row)
          semester.merge! withdrawal_status
        end
      end
    end

    def map_withdrawal_status(row)
      {
        hasWithdrawalData: true,
        withdrawalStatus:
          {
            acadcareerCode: row['acadcareer_code'],
            withcnclTypeCode: row['withcncl_type_code'],
            withcnclTypeDescr: row['withcncl_type_descr'],
            withcnclReasonCode: row['withcncl_reason_code'],
            withcnclReasonDescr: row['withcncl_reason_descr'],
            withcnclFromDate:  row['withcncl_fromdate']? row['withcncl_fromdate'].to_date.strftime('%b %d, %Y') : nil,
            withcnclLastAttenDate:  row['withcncl_lastattendate']? row['withcncl_lastattendate'].to_date.strftime('%b %d, %Y'): nil,
          }
      }
    end

    def merge_standings(semester)
      if (standing = academic_standings.find {|row| row['term_id'] == Berkeley::TermCodes.slug_to_edo_id(semester[:slug])})
        standing_data = {
          hasStandingData: true,
          standing: Concerns::AcademicsModule.standings_info(standing)
        }
        semester.merge! standing_data
      end
    end

    def academic_standings
      @academic_standings ||= begin
        academic_standings = EdoOracle::Queries.get_academic_standings(@campus_solutions_id) if Settings.features.standings
        academic_standings ||= []
        academic_standings.sort_by!{|s| [s['term_id'], s['action_date']]}.reverse!
      end
    end

    def has_enrolled_classes?(enrollment_term)
      !!enrollment_term.find do |course|
        if course[:role] == 'Student' && course[:sections]
          course[:sections].find{|section| !section[:waitlisted]}
        end
      end
    end

    def merge_semesters_count(data)
      if data[:semesters]
        past_semesters_count = data[:semesters].select {|sem| sem[:timeBucket] == 'past'}.length
        data[:pastSemestersLimit] = data[:semesters].length - past_semesters_count + 1
        data[:pastSemestersCount] = past_semesters_count
      end
      data
    end

    def process_enrollments(enrollment_term, term_id)
      filtered_enrollment_term = filter_enrollments(enrollment_term)
      filtered_enrollment_term.map do |enrollment|
        mapped_enrollment = course_info enrollment
        if @filtered
          mapped_enrollment.delete :url
        else
          process_unfiltered_enrollment(enrollment, term_id)
        end
        mapped_enrollment
      end.compact
    end

    def filter_enrollments(enrollment_term)
      enrollment_term.reject do |enrollment|
        enrollment[:role] != 'Student' || exclude_enrollment_for_law?(enrollment)
      end
    end

    def exclude_enrollment_for_law?(enrollment)
      return true if current_academic_roles['lawJointDegree'] && !['GRAD','LAW'].include?(enrollment[:academicCareer])
      return true if law_student? && !current_academic_roles['lawJointDegree'] && !academic_careers.include?(enrollment[:academicCareer])
      false
    end

    def current_academic_roles
      @current_academic_roles ||= MyAcademics::MyAcademicRoles.new(@uid).get_feed[:current]
    end

    def process_unfiltered_enrollment(enrollment, term_id)
      primaries_count = 0
      enrollment[:sections].each do |section|
        if section[:is_primary_section]
          add_section_grade_option(section)
          primaries_count += 1
        end
        if section[:waitlisted] && Settings.features.reserved_capacity
          map_reserved_seats(term_id, section)
        end
        if Settings.features.reserved_capacity_link
          add_reserved_seating_rules_link(term_id, enrollment, section)
        end
        section[:grading][:gradePoints] = nil if hide_points? enrollment
        section[:isLaw] = law_class? enrollment
        section.merge!(law_class_enrollment(enrollment, section))
      end
      merge_multiple_primaries(enrollment, enrollment[:course_option]) if primaries_count > 1
    end

    def add_section_grade_option(section)
      if section.has_key? :grading_basis
        section[:gradeOption] = Berkeley::GradeOptions.grade_option_from_basis(section[:grading_basis])
      else
        section[:gradeOption] = Berkeley::GradeOptions.grade_option_for_enrollment(section[:cred_cd], section[:pnp_flag])
      end
    end

    def add_reserved_seating_rules_link(term_id, course, section)
      if section[:waitlisted] && section[:is_primary_section]
        reserved_capacity_count = EdoOracle::Queries.section_reserved_capacity_count(term_id, section[:ccn]).first['reserved_seating_rules_count'].to_i
        if reserved_capacity_count > 0
          term = Berkeley::Terms.find_by_campus_solutions_id(term_id)
          class_subject = course[:dept_code]
          catalog_nbr = course[:courseCatalog]
          class_section = section[:section_number]
          component = section[:instruction_format]
          section[:hasReservedSeats] = true
          section[:reservedSeatsInfoLink] = LinkFetcher.fetch_link('UC_CX_WAITLIST_ACAD_GUIDE_CLS', {
            'TERM_YEAR' => term.year.to_s,
            'TERM_NAME' => term.name.to_s.downcase,
            'CLASS_SUBJECT' => class_subject.to_s.downcase,
            'CATALOG_NBR' => catalog_nbr.to_s.downcase,
            'CLASS_SECTION' => class_section.to_s.downcase,
            'COMPONENT' => component.to_s.downcase,
          })
        end
      end
    end

    def map_reserved_seats(term_id, section)
      section_reserved_capacity = EdoOracle::Queries.get_section_reserved_capacity(term_id, section[:ccn])
      if section_reserved_capacity.any?
        section[:hasReservedSeats] = true
        # get section capacity
        section_capacity = EdoOracle::Queries.get_section_capacity(term_id, section[:ccn])
        unreserved_seats_available = 'N/A'
        if section_capacity.any?
          section_row = section_capacity.first
          section_enrolled_count = section_row['enrolled_count']
          section_max_enroll = section_row['max_enroll']
          # calculate total available unreserved seats
          available_reserved_total = section_reserved_capacity.map {|row| row['reserved_seats'].to_i - row['reserved_seats_taken'].to_i}.sum
          unreserved_seats_available = section_max_enroll.to_i - section_enrolled_count.to_i - available_reserved_total.to_i
        end
        section[:capacity] = {
          unreservedSeats: format_capacity(unreserved_seats_available),
          reservedSeats: []
        }
        section_reserved_capacity.each do |row|
          available_reserved = row['reserved_seats'].to_i - row['reserved_seats_taken'].to_i
          section[:capacity][:reservedSeats].push(
            {
              seats: format_capacity(available_reserved),
              seatsFor: row['requirement_group_descr']
            }
          )
        end
      end
    end

    def format_capacity(capacity_number)
      capacity_number.to_i < 0 ? 'N/A' : capacity_number.to_s
    end

    def law_class_enrollment(course, section)
      if law_class?(course) || law_student?
        enrollment = EdoOracle::Queries.get_law_enrollment(@uid, course[:academicCareer], course[:term_id], section[:ccn], course[:requirementsDesignationCode])
      end
      {
        lawUnits: enrollment.try(:[], 'units_taken_law'),
        requirementsDesignation: enrollment.try(:[], 'rqmnt_desg_descr')
      }
    end

    def merge_grades(semester)
      if semester.try(:[], :timeBucket) == 'current' && semester.try(:[], :classes).length
        semester[:classes].each do |course|
          add_midpoint_grade(course) if course[:role] == 'Student'
        end
      end
    end

    def add_midpoint_grade(course)
      current_enrollments = hub_current_enrollments.try(:[], :feed)
      primary_section = course.try(:[], :sections).to_a.find {|sec| sec[:is_primary_section] }
      primary_enrollment = current_enrollments.try(:find) do |enrollment|
        enrollment.try(:[], 'classSection').try(:[], 'id').try(:to_i) == primary_section.try(:[], :ccn).try(:to_i)
      end
      section_midpoint_grade = primary_enrollment.try(:[], 'grades').try(:find) do |grade|
        grade.try(:[], 'type').try(:[], 'code') == 'MID'
      end
      if section_midpoint_grade.present?
        primary_section[:grading].merge!({midpointGrade: section_midpoint_grade.try(:[], 'mark')})
      end
    end

    def hub_current_enrollments
      if current_term
        @hub_current_enrollments ||= HubEnrollments::MyTermEnrollments.new(user_id: @uid, term_id: current_term.campus_solutions_id).get_feed
      else
        {}
      end
    end

    def hide_points?(course)
      (law_class? course) || (grad_class?(course) && is_concurrent_student)
    end

    def law_student?
      @is_law_student ||= begin
        roles = MyAcademics::MyAcademicRoles.new(@uid).get_feed
        !!roles[:current]['law']
      end
    end

    def law_class?(course)
      :LAW == course[:academicCareer].try(:intern)
    end

    def grad_class?(course)
      :GRAD == course[:academicCareer].try(:intern)
    end

    def is_concurrent_student
      @is_concurrent_student ||= EdoOracle::Student.new(user_id: @uid).concurrent?
    end
  end
end

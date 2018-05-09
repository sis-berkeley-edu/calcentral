module MyAcademics
  class Semesters < UserSpecificModel
    include Concerns::AcademicsModule

    def initialize(uid)
      super(uid)
    end

    def merge(data)
      if (@filtered = data[:filteredForDelegate])
        enrollments = EdoOracle::UserCourses::All.new(user_id: @uid).get_enrollments_summary
      else
        enrollments = EdoOracle::UserCourses::All.new(user_id: @uid).get_all_campus_courses
      end

      campus_solution_id = CalnetCrosswalk::ByUid.new(user_id: @uid).lookup_campus_solutions_id
      reg_status_data = EdoOracle::Queries.get_registration_status(campus_solution_id)

      data[:semesters] = semester_feed(enrollments, reg_status_data).compact
      merge_semesters_count data
    end

    def semester_feed(enrollment_terms, reg_status_data)
      study_prog_data = reg_status_data.select { |row| row['splstudyprog_type_code'].present? }
      withdrawal_data = reg_status_data.select { |row| row['withcncl_type_code'].present? }

      withdrawal_terms = withdrawal_data.map {|row| Berkeley::TermCodes.edo_id_to_code(row['term_id'])}
      study_prog_terms = study_prog_data.map {|row| Berkeley::TermCodes.edo_id_to_code(row['term_id'])}

      # Note: a student should never have withdrawal and absentia or filling fee for same term
      (enrollment_terms.keys | withdrawal_terms | study_prog_terms).sort.reverse.map do |term_key|
        semester = semester_info term_key
        semester[:filteredForDelegate] = !!@filtered
        if enrollment_terms[term_key]
          semester[:hasEnrollmentData] = true
          semester[:classes] = map_enrollments(enrollment_terms[term_key]).compact
          semester[:hasEnrolledClasses] = has_enrolled_classes?(enrollment_terms[term_key])
          merge_grades(semester)
        end
        semester.merge! unit_totals(enrollment_terms[term_key])
        merge_study_prog(semester, study_prog_data)
        merge_withdrawals(semester, withdrawal_data)
        semester unless semester[:classes].empty? && !semester[:hasWithdrawalData] && !semester[:hasStudyProgData]
      end
    end

    def unit_totals(enrollments)
      academic_careers = (enrollments.collect {|enrollment| enrollment[:academicCareer].try(:intern)}).uniq
      unit_totals = EdoOracle::CareerTerm.new(user_id: @uid).term_summary(academic_careers, enrollments.first[:term_id])
      total_law_units = unit_totals[:grading_complete] ? unit_totals[:total_earned_law_units] : unit_totals[:total_enrolled_law_units]
      {
        totalUnits: unit_totals[:grading_complete] ? unit_totals[:total_earned_units] : unit_totals[:total_enrolled_units],
        totalLawUnits: law_student? || academic_careers.include?(:LAW) ? total_law_units : nil,
        isGradingComplete: unit_totals[:grading_complete]
      }
    end

    def merge_study_prog(semester, filing_fee_data)
      filing_fee_data.each do |row|
        if row['term_id'] == Berkeley::TermCodes.slug_to_edo_id(semester[:slug])
          semester.merge! map_study_prog(row)
        end
      end
    end

    def map_study_prog(row)
      {
        hasStudyProgData: true,
        studyProg:
          {
            studyprogTypeCode: row['splstudyprog_type_code'],
            studyprogTypeDescr: row['splstudyprog_type_descr'],
          }
      }
    end

    def merge_withdrawals (semester, withdrawal_data)
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

    def map_enrollments(enrollment_term)
      enrollment_term.map do |course|
        next unless course[:role] == 'Student'
        mapped_course = course_info course
        if @filtered
          mapped_course.delete :url
        else
          primaries_count = 0
          mapped_course[:sections].each do |section|
            if section[:is_primary_section]
              if section.has_key? :grading_basis
                section[:gradeOption] = Berkeley::GradeOptions.grade_option_from_basis(section[:grading_basis])
              else
                section[:gradeOption] = Berkeley::GradeOptions.grade_option_for_enrollment(section[:cred_cd], section[:pnp_flag])
              end
              primaries_count += 1
            end
            section[:grading][:grade_points] = nil if law_class? course
            section.merge!(law_class_enrollment(course, section))
          end
          merge_multiple_primaries(mapped_course, course[:course_option]) if primaries_count > 1
        end
        mapped_course
      end
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
      course.try(:[], :sections).try(:each) do |section|
        if section.try(:[], :is_primary_section)
          section_midpoint_grade = current_enrollments.try(:find) do |enrollment|
            # Find the relevant enrollment object, matching on CCN
            enrollment.try(:[], 'classSection').try(:[], 'id').try(:to_i) == section.try(:[], :ccn).try(:to_i)
          end.try(:[], 'grades').try(:find) do |grade|
            # Return the object containing the midpoint grade
            grade.try(:[], 'type').try(:[], 'code') == 'MID'
          end.try(:[], 'mark')
          section[:grading].merge!({midpointGrade: section_midpoint_grade}) if section_midpoint_grade.present?
        end
      end
    end

    def hub_current_enrollments
      if current_term
        @hub_current_enrollments ||= HubEnrollments::MyTermEnrollments.new(user_id: @uid, term_id: current_term.campus_solutions_id).get_feed
      else
        {}
      end
    end

    def law_student?
      roles = MyAcademics::MyAcademicRoles.new(@uid).get_feed
      !!roles['law']
    end

    def law_class?(course)
      :LAW == course[:academicCareer].try(:intern)
    end

  end
end

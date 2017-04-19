module MyAcademics
  class Semesters
    include AcademicsModule

    def initialize(uid)
      super(uid)
    end

    def merge(data)

      if (@filtered = data[:filteredForDelegate])
        enrollments = EdoOracle::UserCourses::All.new(user_id: @uid).get_enrollments_summary
        enrollments.merge!(CampusOracle::UserCourses::All.new(user_id: @uid).get_enrollments_summary) if Settings.features.allow_legacy_fallback
      else
        enrollments = EdoOracle::UserCourses::All.new(user_id: @uid).get_all_campus_courses
        enrollments.merge!(CampusOracle::UserCourses::All.new(user_id: @uid).get_all_campus_courses) if Settings.features.allow_legacy_fallback
      end

      campus_solution_id = CalnetCrosswalk::ByUid.new(user_id: @uid).lookup_campus_solutions_id
      withdrawal_data = EdoOracle::Queries.get_withdrawal_status(campus_solution_id)

      if Settings.features.allow_legacy_fallback
        transcripts =  CampusOracle::UserCourses::Transcripts.new(user_id: @uid).get_all_transcripts
        data[:additionalCredits] = transcripts[:additional_credits] if transcripts[:additional_credits].any?
      end

      transcript_terms = transcripts ? transcripts[:semesters] : {}
      data[:semesters] = semester_feed(enrollments, transcript_terms, withdrawal_data).compact
      merge_semesters_count data
    end

    def semester_feed(enrollment_terms, transcript_terms, withdrawal_data)
      (enrollment_terms.keys | transcript_terms.keys).sort.reverse.map do |term_key|
        semester = semester_info term_key
        semester.delete :slug if @filtered
        if enrollment_terms[term_key]
          semester[:hasEnrollmentData] = true
          semester[:summaryFromTranscript] = (semester[:timeBucket] == 'past')
          semester[:classes] = map_enrollments(enrollment_terms[term_key]).compact
          semester[:hasEnrolledClasses] = has_enrolled_classes?(enrollment_terms[term_key])
          merge_grades(semester, transcript_terms[term_key])
          merge_withdrawals(semester, withdrawal_data)
        elsif Settings.features.allow_legacy_fallback
          semester[:hasEnrollmentData] = false
          semester[:summaryFromTranscript] = true
          semester[:hasEnrolledClasses] = false
          semester[:classes] = map_transcripts transcript_terms[term_key][:courses]
          semester[:notation] = translate_notation transcript_terms[term_key][:notations]
        end
        semester unless semester[:classes].empty?
      end
    end

    def merge_withdrawals (semester, withdrawal_data)
      withdrawal_data.each do |row|
        if row['term_id'] == Berkeley::TermCodes.slug_to_edo_id(semester[:slug])
          withdrawal_status =
            {
              hasWithdrawalData: true,
              withdrawalStatus:
                {
                  acadcareerCode: row['acadcareer_code'],
                  withcnclTypeCode: row['withcncl_type_code'],
                  withcnclTypeDescr: row['withcncl_type_descr'],
                  withcnclReasonCode: row['withcncl_reason_code'],
                  withcnclReasonDescr: row['withcncl_reason_descr'],
                  withcnclFromDate:  row['withcncl_fromdate'].to_date.strftime('%b %d, %Y'),
                  withcnclLastAttenDate:  row['withcncl_lastattendate'].to_date.strftime('%b %d, %Y'),
                }
            }
          semester.merge! withdrawal_status
        end
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
        past_semesters_count += 1 if data[:additionalCredits]
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
          end
          merge_multiple_primaries(mapped_course, course[:course_option]) if primaries_count > 1
        end
        mapped_course
      end
    end

    def map_transcripts(transcript_courses)
      return [] if !transcript_courses
      transcript_courses.map do |course|
        course.slice(:title, :dept, :courseCatalog).merge({
          course_code: [course[:dept], course[:courseCatalog]].select(&:present?).join(' '),
          sections: [],
          transcript: [course.slice(:units, :grade)]
        })
      end
    end

    def merge_grades(semester, transcript_term)
      semester[:classes].each do |course|
        grade_sources = nil
        if use_enrollment_grades?(semester)
          grade_sources = course[:sections].select { |s| s[:is_primary_section] && s[:grade] }
        elsif use_transcript_grades?(semester) && transcript_term && transcript_term[:courses]
          grade_sources = transcript_term[:courses].select { |t| t[:dept] == course[:dept] && t[:courseCatalog] == course[:courseCatalog] }
        end
        course[:transcript] = grade_sources.map { |e| e.slice(:units, :grade, :grade_points) } if grade_sources.present?
      end

      if transcript_term && transcript_term[:courses]
        incomplete_removals = transcript_term[:courses].select { |t| t[:title] == 'Incomplete Removed' }
        if incomplete_removals.any?
          semester[:classes].concat map_transcripts(incomplete_removals)
        end
      end

      if semester.try(:[], :timeBucket) == 'current' && semester.try(:[], :classes).length
        semester[:classes].each do |course|
          add_midpoint_grade(course) if course[:role] == 'Student'
        end
      end
    end

    def add_midpoint_grade(course)
      current_enrollments = hub_current_enrollments.try(:[], :feed)
      primary_section = course.try(:[], :sections).try(:find) do |section|
        section.try(:[], :is_primary_section)
      end
      section_midpoint_grade = current_enrollments.try(:find) do |enrollment|
        # Find the relevant enrollment object, matching on CCN
        enrollment.try(:[], 'classSection').try(:[], 'id').try(:to_i) == primary_section.try(:[], :ccn).try(:to_i)
      end.try(:[], 'grades').try(:find) do |grade|
        # Return the object containing the midpoint grade
        grade.try(:[], 'type').try(:[], 'code') == 'MID'
      end.try(:[], 'mark')
      course.merge!({midpointGrade: section_midpoint_grade})
    end

    def hub_current_enrollments
      if current_term
        @hub_current_enrollments ||= HubEnrollments::MyTermEnrollments.new(user_id: @uid, term_id: current_term.campus_solutions_id).get_feed
      else
        {}
      end
    end

    def translate_notation(transcript_notations)
      return unless transcript_notations
      if transcript_notations.include? 'extension'
        'UC Extension'
      elsif transcript_notations.include? 'abroad'
        'Education Abroad'
      end
    end

    def use_enrollment_grades?(semester)
      return true unless Settings.features.allow_legacy_fallback
      semester[:timeBucket] == 'current' || semester[:gradingInProgress] || semester[:campusSolutionsTerm] ||  semester[:slug] == Settings.terms.legacy_cutoff
    end

    def use_transcript_grades?(semester)
      semester[:timeBucket] == 'past' && !semester[:gradingInProgress] && !semester[:campusSolutionsTerm] && Settings.features.allow_legacy_fallback
    end

  end
end

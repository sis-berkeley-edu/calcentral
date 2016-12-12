module MyAcademics
  class Semesters
    include AcademicsModule

    def initialize(uid)
      super(uid)
    end

    def merge(data)
      legacy_user_courses = CampusOracle::UserCourses::All.new(user_id: @uid)
      edo_user_courses = EdoOracle::UserCourses::All.new(user_id: @uid)

      if (@filtered = data[:filteredForDelegate])
        enrollments = legacy_user_courses.get_enrollments_summary.merge(edo_user_courses.get_enrollments_summary)
      else
        enrollments = legacy_user_courses.get_all_campus_courses.merge(edo_user_courses.get_all_campus_courses)
      end

      transcripts = CampusOracle::UserCourses::Transcripts.new(user_id: @uid).get_all_transcripts

      data[:additionalCredits] = transcripts[:additional_credits] if transcripts[:additional_credits].any?
      data[:semesters] = semester_feed(enrollments, transcripts[:semesters]).compact
      merge_semesters_count data
    end

    def semester_feed(enrollment_terms, transcript_terms)
      (enrollment_terms.keys | transcript_terms.keys).sort.reverse.map do |term_key|
        semester = semester_info term_key
        semester.delete :slug if @filtered
        if enrollment_terms[term_key]
          semester[:hasEnrollmentData] = true
          semester[:summaryFromTranscript] = (semester[:timeBucket] == 'past')
          semester[:classes] = map_enrollments(enrollment_terms[term_key]).compact
          semester[:hasEnrolledClasses] = has_enrolled_classes?(enrollment_terms[term_key])
          merge_grades(semester, transcript_terms[term_key])
        else
          semester[:hasEnrollmentData] = false
          semester[:summaryFromTranscript] = true
          semester[:hasEnrolledClasses] = false
          semester[:classes] = map_transcripts transcript_terms[term_key][:courses]
          semester[:notation] = translate_notation transcript_terms[term_key][:notations]
        end
        semester unless semester[:classes].empty?
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
        course[:transcript] = grade_sources.map { |e| e.slice(:units, :grade) } if grade_sources.present?
      end

      if transcript_term && transcript_term[:courses]
        incomplete_removals = transcript_term[:courses].select { |t| t[:title] == 'Incomplete Removed' }
        if incomplete_removals.any?
          semester[:classes].concat map_transcripts(incomplete_removals)
        end
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
      semester[:timeBucket] == 'current' || semester[:gradingInProgress] || semester[:campusSolutionsTerm]
    end

    def use_transcript_grades?(semester)
      semester[:timeBucket] == 'past' && !semester[:gradingInProgress] && !semester[:campusSolutionsTerm]
    end

  end
end

module MyAcademics
  class AcademicPlan < UserSpecificModel
    include AdvisingAcademicPlannerFeatureFlagged

    def merge(data)
      if is_feature_enabled
        data[:planSemesters] = get_plan_semesters(data[:semesters])
      end
    end

    def get_plan_semesters(semesters)
      plan_semesters = []
      plans = []
      all_terms = parse_all_possible_terms(semesters)
      all_terms.each do |term_id|
        plan_semesters << build_term_plan_semester(term_id, plans, semesters)
      end
      add_prev_next(plan_semesters)
    end

    def build_term_plan_semester(term_id, plans, semesters)
      term_codes = Berkeley::TermCodes.from_edo_id(term_id)
      slug = Berkeley::TermCodes.to_slug(term_codes[:term_yr], term_codes[:term_cd])
      semester = {
        edoId: term_id,
        name:  Berkeley::TermCodes.to_english(term_codes[:term_yr], term_codes[:term_cd]),
        slug: slug,
        termCode: term_codes[:term_cd],
        termYear: term_codes[:term_yr],
        timeBucket: Concerns::AcademicsModule.time_bucket(term_codes[:term_yr], term_codes[:term_cd]),
      }
      semester.merge parse_enrolled_classes(slug, semesters)
    end

    def add_prev_next(plan_semesters)
      plan_semesters.each_with_index do |semester, i |
        semester[:timeBucket] = 'next' if i > 0 && plan_semesters[i-1][:timeBucket] == 'current'
        semester[:timeBucket] = 'previous' if i < plan_semesters.count - 1 && plan_semesters[i+1][:timeBucket] == 'current'
      end
      plan_semesters
    end

    def parse_enrolled_classes(slug, semesters)
      semester = semesters.find { |s| s[:slug] == slug}
      {
        campusSolutionsTerm: semester.try(:[], :campusSolutionsTerm),
        hasEnrollmentData:  semester.try(:[], :hasEnrollmentData),
        hasEnrolledClasses:  semester.try(:[], :hasEnrolledClasses),
        enrolledClasses:  semester.try(:[], :classes),
        notation:  semester.try(:[], :notation),
        hasWaitlisted: has_waitlisted_classes?(semester),
        hasStudyProgData: semester.try(:[], :hasStudyProgData),
        studyProg: semester.try(:[], :studyProg),
        hasWithdrawalData: semester.try(:[], :hasWithdrawalData),
        withdrawalStatus:  semester.try(:[], :withdrawalStatus),
        hasStandingData: semester.try(:[], :hasStandingData),
        standing: semester.try(:[], :standing)
      }.merge calc_enrolled_units(semester)
    end

    def calc_enrolled_units(semester)
      enrolled_units = 0.0
      waitlisted_units = 0.0
      semester.try(:[], :classes).try(:each) do |cls|
        cls.try(:[], :sections).try(:each) do |section|
          if section[:waitlisted] && section[:is_primary_section]
            waitlisted_units += section[:units].to_f
          elsif section[:is_primary_section]
            enrolled_units += section[:units].to_f
          end
        end
      end
      {
        enrolledUnits: enrolled_units.to_f.to_s,
        waitlistedUnits: waitlisted_units.to_f.to_s
      }
    end

    def has_waitlisted_classes?(semester)
      return false unless semester
      !!semester.try(:[], :classes).try(:find) do |cls|
          !!cls[:sections].try(:find) do |section|
            section[:waitlisted]
          end
      end
    end

    def parse_all_possible_terms(semesters)
      term_codes = []
      term_codes << parse_all_semester_terms(semesters)
      term_codes.flatten.compact.uniq.sort
    end

    def parse_all_semester_terms(semesters)
      semester_term_codes = []
      semesters.try(:each) do |semester|
        semester_term_codes << Berkeley::TermCodes.slug_to_edo_id(semester[:slug])
      end
      semester_term_codes
    end
  end
end

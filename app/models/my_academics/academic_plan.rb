module MyAcademics
  class AcademicPlan < UserSpecificModel
    include AdvisingAcademicPlannerFeatureFlagged

    def merge(data)
      if is_feature_enabled
        update_url_proxy = CampusSolutions::AcademicPlan.new(user_id: @uid).get
        data[:updatePlanUrl] = update_url_proxy.try(:[], :feed).try(:[], :updateAcademicPlanner).try(:[], :url)
        data[:planSemesters] = get_plan_semesters(data[:semesters])
      end
    end

    def get_plan_semesters(semesters)
      plan_semesters = []
      plans = CampusSolutions::AdvisingAcademicPlan.new(user_id: @uid).get
      all_terms = parse_all_possible_terms(plans, semesters)
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
        timeBucket: MyAcademics::AcademicsModule.time_bucket(term_codes[:term_yr], term_codes[:term_cd]),
      }
      semester.merge! parse_planned_classes(term_id, plans)
      semester.merge parse_enrolled_classes(slug, semesters)
    end

    def add_prev_next(plan_semesters)
      plan_semesters.each_with_index do |semester, i |
        semester[:timeBucket] = 'next' if i > 0 && plan_semesters[i-1][:timeBucket] == 'current'
        semester[:timeBucket] = 'previous' if i < plan_semesters.count - 1 && plan_semesters[i+1][:timeBucket] == 'current'
      end
      plan_semesters
    end

    def parse_planned_classes(term_id, plans)
      planned_classes = []
      plans[:feed].try(:[], :acadPlans).try(:each) do |plan|
        planned_classes << find_classes_in_plan(term_id, plan)
      end
      planned_classes = planned_classes.flatten.uniq
      {
        plannedClasses: planned_classes,
        plannedUnits: calc_planned_units(planned_classes)
      }
    end

    def calc_planned_units(planned_classes)
      planned_classes.map {|cls| cls[:units].to_f}.sum.to_f.to_s
    end

    def find_classes_in_plan(term_id, plan)
      terms_array = plan.try(:[],:terms).try(:[],:term)
      terms_array =  terms_array.blank? || terms_array.kind_of?(Array) ? terms_array : [] << terms_array
      plan_term = terms_array.try(:find) do |plan_term|
        plan_term[:termId] == term_id
      end
      parse_plan_term_classes(plan_term)
    end

    def parse_plan_term_classes(plan_term)
      planned_classes = []
      plan_term.try(:[], :plannedClasses).try(:each) do |planned_class|
        planned_classes << {
          subjectArea: planned_class[:subjectArea],
          catalogNumber: planned_class[:catalogNumber],
          units: planned_class[:units]
        }
      end
      planned_classes
    end

    def parse_enrolled_classes(slug, semesters)
      semester = semesters.find { |s| s[:slug] == slug}
      {
        campusSolutionsTerm: semester.try(:[], :campusSolutionsTerm),
        hasEnrollmentData:  semester.try(:[], :hasEnrollmentData),
        hasEnrolledClasses:  semester.try(:[], :hasEnrolledClasses),
        summaryFromTranscript:  semester.try(:[], :summaryFromTranscript),
        enrolledClasses:  semester.try(:[], :classes),
        notation:  semester.try(:[], :notation),
        hasWaitlisted: has_waitlisted_classes?(semester),
        hasClassTranscript: has_class_transcript?(semester)
      }.merge calc_enrolled_units(semester)
    end

    def calc_enrolled_units(semester)
      enrolled_units = 0.0
      waitlisted_units = 0.0
      semester.try(:[], :classes).try(:each) do |cls|
        enrolled_units += cls.try(:[], :transcript).try(:map){ |tran| tran[:units].to_f }.try(:sum).to_f
        cls.try(:[], :sections).try(:each) do |section|
          if section[:waitlisted] && section[:is_primary_section]
            waitlisted_units += section[:units].to_f
          elsif section[:is_primary_section] && !semester[:summaryFromTranscript]
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
      return false unless semester && !semester[:summaryFromTranscript] && semester[:hasEnrolledClasses]
      !!semester.try(:[], :classes).try(:find) do |cls|
          !!cls[:sections].try(:find) do |section|
            section[:waitlisted]
          end
      end
    end

    def has_class_transcript?(semester)
      return false unless semester && semester[:summaryFromTranscript]
      !!semester.try(:[], :classes).try(:find) do |cls|
        cls[:transcript].present?
      end
    end

    def parse_all_possible_terms(plans, semesters)
      term_codes = []
      term_codes << parse_all_plan_terms(plans)
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

    def parse_all_plan_terms(plans)
      plan_term_codes = []
      plans[:feed].try(:[], :acadPlans).try(:each) do |plan|
        terms_array = plan.try(:[],:terms).try(:[],:term)
        terms_array =  terms_array.blank? || terms_array.kind_of?(Array) ? terms_array : [] << terms_array
        terms_array.try(:each) do |plan_term|
          plan_term_codes << plan_term[:termId]
        end
      end
      plan_term_codes
    end

  end
end

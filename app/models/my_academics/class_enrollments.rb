module MyAcademics
  class ClassEnrollments < UserSpecificModel
    include SafeJsonParser
    include Cache::CachedFeed
    include Cache::UserCacheExpiry
    include CampusSolutions::EnrollmentCardFeatureFlagged
    include Concerns::AcademicStatus
    include LinkFetcher

    ENROLLMENT_DECK_KEYS = ['fpf', 'haasFullTimeMba', 'haasEveningWeekendMba', 'haasExecMba', 'summerVisitor', 'law', 'concurrent']

    def get_feed_internal
      return {} unless is_feature_enabled && user_is_student?
      HashConverter.camelize({
        enrollmentTermInstructionTypeDecks: get_career_term_role_decks,
        enrollmentTermInstructions: get_enrollment_term_instructions,
        enrollmentTermAcademicPlanner: get_enrollment_term_academic_planner,
        hasHolds: has_holds?(MyAcademics::MyAcademicStatus.new(@uid).get_feed),
        links: get_links
      })
    end

    # Groups student plans into groups based on roles (e.g. 'default', 'fpf', 'concurrent')
    def grouped_student_plan_roles
      grouped_roles = {
        :data => {},
        :metadata => {
          :includes_fpf => false
        }
      }
      academic_statuses(MyAcademics::MyAcademicStatus.new(@uid).get_feed).each do |status|
        career_role = status.try(:[], 'studentCareer').try(:[], :role)
        career_code = status.try(:[], 'studentCareer').try(:[], 'academicCareer').try(:[], 'code')

        status.try(:[], 'studentPlans').each do |plan|
          role = determine_enrollment_specific_role(plan[:role], career_role)
          role_key = [role, career_code]
          grouped_roles[:data][role_key] = { role: role, career_code: career_code, academic_plans: [] } if grouped_roles[:data][role_key].blank?
          grouped_roles[:data][role_key][:academic_plans] << plan
          grouped_roles[:metadata][:includes_fpf] = true if role == 'fpf'
        end
      end
      grouped_roles
    end

    def determine_enrollment_specific_role(plan_based_role, career_based_role)
      if ENROLLMENT_DECK_KEYS.include? plan_based_role
        return plan_based_role
      elsif ENROLLMENT_DECK_KEYS.include? career_based_role
        return career_based_role
      end
      'default'
    end

    def get_career_term_role_decks
      career_term_roles = get_career_term_roles
      return [] if career_term_roles.empty?
      if has_multiple_career_term_roles_in_any_term?(career_term_roles)
        return career_term_roles.group_by {|ctr| ctr[:role] }.values.collect {|card_array| {cards: card_array} }
      end
      [{cards: career_term_roles}]
    end

    def has_multiple_career_term_roles_in_any_term?(career_term_roles)
      grouped_by_term = career_term_roles.group_by { |ctr| ctr[:term][:termId] }
      !!grouped_by_term.keys.find do |term_key|
        grouped_by_term[term_key].length > 1
      end
    end

    # Returns unique couplings of current career-terms and current student plan roles
    def get_career_term_roles
      career_terms = get_active_career_terms
      grouped_roles = grouped_student_plan_roles
      career_term_plan_roles = []

      grouped_roles[:data].keys.each do |role_key|
        student_plan_role = grouped_roles[:data][role_key]
        career_terms.each do |career_term|
          if (student_plan_role[:career_code] == career_term[:acadCareer])
            career_term_plan_roles << student_plan_role.merge({term: career_term.slice(:termId, :termDescr, :termName, :termIsSummer)})
          end
        end
      end
      if grouped_roles[:metadata][:includes_fpf]
        return limit_to_single_fpf_career_term_plan_role(career_term_plan_roles)
      end
      career_term_plan_roles
    end

    # Hack to ensure that FPF role is only applied to the first applicable career term plan
    # Logic only valid for Fall 2016 to Spring 2017 transition
    # See SISRP-25837 / SISRP-26815
    def limit_to_single_fpf_career_term_plan_role(career_term_plan_roles)
      career_term_plan_roles_grouped_by_role = career_term_plan_roles.group_by { |plan_role| plan_role[:role] }
      career_term_plan_roles_grouped_by_term = career_term_plan_roles.group_by { |plan_role| plan_role[:term][:termId] }

      # Obtain terms with FPF roles
      fpf_term_ids = career_term_plan_roles_grouped_by_role['fpf'].to_a.collect {|plan_role| plan_role[:term].try(:[], :termId) }.uniq.sort

      # segregate plans from first term containing FPF plan, and other remaining terms
      other_term_plan_roles = career_term_plan_roles_grouped_by_term.slice!(fpf_term_ids.first).values.flatten

      first_fpf_term_plan_roles = career_term_plan_roles_grouped_by_term

      # Isolate earliest FPF career_term_plan_role
      first_fpf_role = first_fpf_term_plan_roles.values[0].to_a.select { |plan_role| plan_role[:role] == 'fpf' }.first

      # force remaining roles to be default
      default_role = 'default'
      other_term_plan_roles.collect do |plan_role|
        if plan_role[:role] == 'fpf'
          plan_role[:role] = default_role
          plan_role[:academic_plans].each do |plan|
            plan[:role] = default_role
          end
        end
      end

      converted_remaining_plan_roles = filter_duplicate_plan_roles(other_term_plan_roles.to_a)
      [first_fpf_role] + converted_remaining_plan_roles
    end

    # Removes duplicate plan roles within the same term
    def filter_duplicate_plan_roles(career_term_plan_roles)
      career_term_plan_roles.inject({}) { |map, plan_role| map[[plan_role[:term][:termId], plan_role[:role]]] = plan_role; map}.values
    end

    def get_enrollment_term_academic_planner
      plans = {}
      get_active_term_ids.collect do |term_id|
        academic_plan = CampusSolutions::AcademicPlan.new(user_id: @uid, term_id: term_id).get
        plans[term_id] = academic_plan.try(:[], :feed)
      end
      plans
    end

    def get_enrollment_term_instructions
      instructions = {}
      get_active_term_ids.each do |term_id|
        instructions[term_id] = CampusSolutions::MyEnrollmentTerm.get_term(@uid, term_id)
        instructions[term_id][:concurrentApplyDeadline] = get_concurrent_apply_deadline(term_id)
        instructions[term_id][:termIsSummer] = Berkeley::TermCodes.edo_id_is_summer?(term_id)
        apply_period_timezones(instructions[term_id])
      end
      instructions
    end

    def apply_period_timezones(instruction)
      if schedule_of_classes_period = instruction.try(:[], :scheduleOfClassesPeriod)
        if soc_date = schedule_of_classes_period.try(:[], :date)
          instruction[:scheduleOfClassesPeriod][:date][:offset] = get_timezone_offset(soc_date)
        end
      end
      if enrollment_periods = instruction.try(:[], :enrollmentPeriod)
        enrollment_periods.each_with_index do |period, index|
          if period_date = period.try(:[], :date)
            instruction[:enrollmentPeriod][index][:date][:offset] = get_timezone_offset(period_date)
          end
        end
      end
    end

    def get_timezone_offset(cs_date_object)
      return nil unless cs_date_object.present?
      if datetime_string = cs_date_object.try(:[], :datetime)
        datetime = DateTime.parse(datetime_string)
        return datetime.strftime('%z')
      end
      nil
    end

    def get_active_term_ids
      career_terms = get_active_career_terms
      return [] if career_terms.empty?
      career_terms.collect {|term| term[:termId] }.uniq
    end

    def get_active_career_terms
      get_career_terms = Proc.new do
        terms = CampusSolutions::MyEnrollmentTerms.get_terms(@uid)
        terms.collect do |term|
          term[:termName] = Berkeley::TermCodes.normalized_english(term[:termDescr])
          term[:termIsSummer] = Berkeley::TermCodes.edo_id_is_summer?(term[:termId])
          term
        end
      end
      @career_terms ||= get_career_terms.call
    end

    def get_links
      cs_links = {}

      campus_solutions_link_settings = [
        { feed_key: :uc_add_class_enrollment, cs_link_key: 'UC_CX_GT_SSCNTENRL_ADD', cs_link_params: {} },
        { feed_key: :uc_edit_class_enrollment, cs_link_key: 'UC_CX_GT_SSCNTENRL_UPD', cs_link_params: {} },
        { feed_key: :uc_view_class_enrollment, cs_link_key: 'UC_CX_GT_SSCNTENRL_VIEW', cs_link_params: {} },
        { feed_key: :request_late_class_changes, cs_link_key: 'UC_CX_GT_GRADEOPT_ADD', cs_link_params: {} },
        { feed_key: :cross_campus_enroll, cs_link_key: 'UC_CX_STDNT_CRSCAMPENR', cs_link_params: {} },
      ]

      campus_solutions_link_settings.each do |setting|
        link = fetch_link(setting[:cs_link_key], setting[:cs_link_params])
        cs_links[setting[:feed_key]] = link unless link.blank?
      end

      cs_links
    end

    def get_concurrent_apply_deadline(term_id)
      get_concurrent_apply_deadlines_hash[term_id.to_s].try(:deadline_date) || "TBD"
    end

    def get_concurrent_apply_deadlines_hash
      deadlines_array = Settings.class_enrollment.try(:concurrent_apply_deadlines)
      deadlines = {}
      if deadlines_array.to_a.count > 0
        deadlines = deadlines_array.inject({}) do |map, term_deadline|
          map[term_deadline.term_code.to_s] = term_deadline
          map
        end
      end
      deadlines
    end

    private

    def user_is_student?
      HubEdos::UserAttributes.new(user_id: @uid).has_role?(:student)
    end
  end
end

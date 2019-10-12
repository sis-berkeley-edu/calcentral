module MyAcademics
  class ClassEnrollments < UserSpecificModel
    include SafeJsonParser
    include Cache::CachedFeed
    include Cache::UserCacheExpiry
    include CampusSolutions::EnrollmentCardFeatureFlagged
    include Concerns::AcademicRoles
    include LinkFetcher

    ENROLLMENT_DECK_KEYS = ['fpf', 'haasFullTimeMba', 'haasEveningWeekendMba', 'haasExecMba', 'summerVisitor', 'courseworkOnly', 'law', 'concurrent']

    def get_feed_internal
      return {} unless is_feature_enabled && user_is_student?
      HashConverter.camelize({
        enrollmentTermInstructionTypeDecks: get_career_term_role_decks,
        enrollmentTermInstructions: get_enrollment_term_instructions,
        enrollmentTermAcademicPlanner: get_enrollment_term_academic_planner,
        hasHolds: MyAcademics::MyAcademicStatus.has_holds?(@uid),
        links: get_links,
        messages: get_messages,
      })
    end

    def get_enrollment_plan_role(term_cpp)
      career_role = get_academic_career_roles(term_cpp['acad_career']).first
      plan_based_roles = get_academic_plan_roles(term_cpp['acad_plan']).try(:uniq)
      determine_enrollment_specific_role(plan_based_roles, career_role)
    end

    def build_plan(role, code)
      {
        role: role,
        plan: {
          code: code
        }
      }
    end

    def determine_enrollment_specific_role(plan_based_roles, career_based_role)
      if plan_based_roles.include? 'fpf'
        return 'fpf'
      elsif (ENROLLMENT_DECK_KEYS & plan_based_roles).any?
        return plan_based_roles.first
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

      grouped_roles.keys.each do |role_key|
        student_plan_role = grouped_roles[role_key]
        career_terms.each do |career_term|
          if (student_plan_role[:career_code] == career_term[:acadCareer] && student_plan_role[:term_id] == career_term[:termId])
            career_term_plan_roles << student_plan_role.merge({term: career_term.slice(:termId, :termDescr, :termName, :termIsSummer)})
          end
        end
      end
      career_term_plan_roles
    end

    # Groups student plans into groups based on roles (e.g. 'default', 'fpf', 'concurrent')
    def grouped_student_plan_roles
      grouped_roles = {}
      current_term_cpp = get_current_and_future_cpp
      current_term_cpp.each do |term_cpp|
        term_id = term_cpp['term_id']
        career_code = term_cpp['acad_career']
        role = get_enrollment_plan_role(term_cpp)
        role_key = [role, career_code, term_id]
        grouped_roles[role_key] = { role: role, career_code: career_code, term_id: term_id, academic_plans: []} if grouped_roles[role_key].blank?
        grouped_roles[role_key][:academic_plans] << build_plan(role, term_cpp['acad_plan'])
      end
      grouped_roles
    end

    def get_current_and_future_cpp
      user = User::Current.new(@uid)
      term_plans = User::Academics::TermPlans::TermPlansCached.new(user).get_feed
      current_term = Berkeley::Terms.fetch.current.try(:campus_solutions_id)
      term_plans.select {|t| t['term_id'].to_s >= current_term.to_s }
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
        instructions[term_id][:termIsSummer] = Berkeley::TermCodes.edo_id_is_summer?(term_id)
        parse_early_drop_deadline_classes(instructions[term_id])
        apply_period_timezones(instructions[term_id])
      end
      instructions
    end

    def parse_early_drop_deadline_classes(instruction)
      instruction[:earlyDropDeadlineClasses] = nil
      early_drop_deadline_classes = nil
      if classes = instruction.try(:[], :enrolledClasses)
        early_drop_deadline_classes = classes.collect do |c|
          c[:edd] == 'Y' ? c[:subjectCatalog] : nil
        end.compact.uniq
      end
      if early_drop_deadline_classes.present?
        instruction[:earlyDropDeadlineClasses] = early_drop_deadline_classes.join(', ')
      end
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
      @career_terms ||= begin
        terms = CampusSolutions::MyEnrollmentTerms.get_terms(@uid).to_a
        terms.collect do |term|
          term[:termName] = Berkeley::TermCodes.normalized_english(term[:termDescr])
          term[:termIsSummer] = Berkeley::TermCodes.edo_id_is_summer?(term[:termId])
          term
        end
      end
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

    def get_messages
      message_keys = [:waitlisted_units_warning]
      CampusSolutions::MessageCatalog.get_message_collection(message_keys)
    end

    private

    def user_is_student?
      HubEdos::UserAttributes.new(user_id: @uid).has_role?(:student)
    end
  end
end

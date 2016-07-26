module MyAcademics
  class ClassEnrollments < UserSpecificModel
    include SafeJsonParser
    include Cache::CachedFeed
    include Cache::UserCacheExpiry
    include CampusSolutions::EnrollmentCardFeatureFlagged

    # Used to identify different enrollment instruction presentations
    ENROLLMENT_INSTRUCTION_TYPES = {
      plan: [
        {instruction_type_code: 'fpf', match: '25000FPFU'},
        {instruction_type_code: 'haas_mba', match: '70141MBAG'},
        {instruction_type_code: 'haas_ewmba', match: '701E1MBAG'},
        {instruction_type_code: 'haas_execmba', match: '70364MBAG'},
      ],
      career: [
        {instruction_type_code: 'law', match: 'LAW'},
        {instruction_type_code: 'ucbx', match: 'UCBX'},
      ]
    }

    def get_feed_internal
      return {} unless is_feature_enabled && user_is_student?
      HashConverter.camelize({
        enrollmentTermInstructionTypes: get_enrollment_term_instruction_types,
        enrollmentTermInstructions: get_enrollment_term_instructions,
        enrollmentTermAcademicPlanner: get_enrollment_term_academic_planner,
        hasHolds: user_has_holds?
      })
    end

    def get_enrollment_term_instruction_types
      career_terms = get_active_career_terms
      instruction_types = get_enrollment_instruction_types
      term_instruction_types = []
      instruction_types.keys.each do |type_key|
        instruction_type = instruction_types[type_key]
        career_terms.each do |career_term|
          if (instruction_type[:career_code] == career_term[:acadCareer])
            term_instruction_types << instruction_type.merge({term: career_term.slice(:termId, :termDescr)})
          end
        end
      end
      term_instruction_types
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
      get_active_term_ids.collect do |term_id|
        term_details = CampusSolutions::EnrollmentTerm.new(user_id: @uid, term_id: term_id).get
        instructions[term_id] = term_details.try(:[], :feed).try(:[], :enrollmentTerm)
      end
      instructions
    end

    def user_has_holds?
      has_holds = false
      json_holds_feed = CampusSolutions::MyHolds.new(@uid).get_feed
      holds_feed = safe_json(json_holds_feed)
      if (holds_feed['statusCode'] == 200)
        service_indicators = holds_feed.try(:[], 'feed').try(:[], 'serviceIndicators')
        has_holds = service_indicators.to_a.length > 0
      end
      has_holds
    end

    def get_enrollment_instruction_types
      types = {}
      get_active_plans.each do |plan|
        type_code = get_enrollment_instruction_type_code(plan)
        career_code = plan[:career][:code]
        type_key = [type_code, career_code]
        types[type_key] = { instruction_type_code: type_code, career_code: career_code, academic_plans: [] } if types[type_key].blank?
        types[type_key][:academic_plans] << plan
      end
      types
    end

    def get_enrollment_instruction_type_code(plan)
      type_codes = []
      ENROLLMENT_INSTRUCTION_TYPES.each do |cpp_category, matchers|
        category_type_codes = matchers.select {|matcher| plan[cpp_category][:code] == matcher[:match]}
        type_codes.concat(category_type_codes)
      end
      type_codes.empty? ? 'default' : type_codes.first[:instruction_type_code]
    end

    def get_active_plans
      active_plans = []
      response = HubEdos::AcademicStatus.new(user_id: @uid).get
      if (status = AcademicsModule.parse_hub_academic_status(response))
        Array.wrap(status.try(:[], 'studentPlans')).each do |plan|
          active_plans << flatten_plan(plan)
        end
      end
      active_plans.compact
    end

    def flatten_plan(plan)
      flat_plan = {career: {}, plan: {}}
      if (academic_plan = plan['academicPlan'])
        plan = academic_plan.try(:[], 'plan')
        academic_program = academic_plan.try(:[], 'academicProgram')
        career = academic_program.try(:[], 'academicCareer')
        program = academic_program.try(:[], 'program')
        flat_plan[:career].merge!({
          code: career.try(:[], 'code'),
          description: career.try(:[], 'description')
        })
        flat_plan[:plan].merge!({
          code: plan.try(:[], 'code'),
          description: plan.try(:[], 'description')
        })
      end
      flat_plan
    end

    def get_active_term_ids
      career_terms = get_active_career_terms
      return [] if career_terms.empty?
      career_terms.collect {|term| term[:termId] }.uniq
    end

    def get_active_career_terms
      get_career_terms = Proc.new do
        terms = CampusSolutions::EnrollmentTerms.new({user_id: @uid}).get
        terms.try(:[], :feed).try(:[], :enrollmentTerms)
      end
      @career_terms ||= get_career_terms.call
    end

    private

    def user_is_student?
      HubEdos::UserAttributes.new(user_id: @uid).has_role?(:student)
    end
  end
end

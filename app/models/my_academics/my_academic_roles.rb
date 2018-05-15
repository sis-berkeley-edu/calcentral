module MyAcademics
  class MyAcademicRoles < UserSpecificModel
    include Cache::CachedFeed
    include Cache::UserCacheExpiry
    include Concerns::AcademicStatus
    include Concerns::AcademicRoles

    def get_feed_internal
      response = MyAcademics::MyAcademicStatus.new(@uid).get_feed
      roles = role_defaults
      assigned_roles = collect_roles academic_statuses(response)

      assigned_roles.each do |role|
        if roles.has_key?(role)
          roles[role] = true
        end
      end
      roles['nonDegreeSeekingSummerVisitor'] = is_non_degree_seeking_summer_visitor?
      roles
    end

    def collect_roles(academic_statuses)
      roles = []
      academic_statuses.try(:each) do |status|
        roles.concat(extract_roles status)
      end
      roles
    end

    def extract_roles(status)
      roles = []
      status.try(:[], 'studentPlans').try(:each) do |plan|
        roles << plan[:role]
        roles << plan.try(:[], 'academicPlan').try(:[], 'academicProgram').try(:[], :role)
      end
      roles << status.try(:[], 'studentCareer').try(:[], :role)
      roles.compact
    end

    def is_non_degree_seeking_summer_visitor?
      term_cpp = MyAcademics::MyTermCpp.new(@uid).get_feed
      program_codes = term_cpp.collect { |row| row['acad_program'] }
      non_degree_seeking_program_codes = ['GNODG', 'LNODG', 'UNODG', 'XCCRT', 'XFPF']

      if is_degree_seeking = (program_codes - non_degree_seeking_program_codes).present?
        false
      else
        plan_role_codes = term_cpp.collect { |row| get_academic_plan_role_code(row['acad_plan']) }
        summer_visitor_plan_role = Concerns::AcademicRoles::ACADEMIC_PLAN_ROLES.find {|role| role[:role_code] == 'summerVisitor'}
        summer_visitor_plan_codes = summer_visitor_plan_role[:match]
        (plan_role_codes - summer_visitor_plan_codes).present?
      end
    end
  end
end

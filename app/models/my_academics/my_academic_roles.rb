module MyAcademics
  class MyAcademicRoles < UserSpecificModel
    include Cache::CachedFeed
    include Cache::UserCacheExpiry
    include Concerns::AcademicStatus
    include Concerns::AcademicRoles

    def get_feed_internal
      {
        current: get_current_roles,
        historical: get_historical_roles
      }
    end

    def get_current_roles
      response = MyAcademics::MyAcademicStatus.new(@uid).get_feed
      roles = role_defaults
      assigned_roles = collect_roles academic_statuses(response)

      map_roles(roles, assigned_roles)
      roles
    end

    def get_historical_roles
      term_cpp = MyAcademics::MyTermCpp.new(@uid).get_feed
      roles = role_defaults
      assigned_roles = []

      term_cpp.each do |term|
        assigned_roles << get_academic_career_roles(term['acad_career'])
        assigned_roles << get_academic_program_roles(term['acad_program'])
        assigned_roles << get_academic_plan_roles(term['acad_plan'])
      end
      assigned_roles.flatten!
      assigned_roles.uniq!

      map_roles(roles, assigned_roles)
      roles
    end

    def map_roles(default_roles, assigned_roles)
      assigned_roles.each do |role|
        if default_roles.has_key?(role)
          default_roles[role] = true
        end
      end
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
  end
end

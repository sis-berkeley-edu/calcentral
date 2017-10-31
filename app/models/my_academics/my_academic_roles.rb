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
  end
end

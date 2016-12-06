module HubEdos
  class MyAcademicStatus < UserSpecificModel
    include Cache::CachedFeed
    include Cache::UserCacheExpiry
    include Berkeley::AcademicRoles

    def get_feed_internal
      feed = HubEdos::AcademicStatus.new({user_id: @uid}).get
      if (academic_statuses = feed.try(:[], :feed).try(:[], 'student').try(:[], 'academicStatuses'))
        feed[:feed]['student']['roles'] = roles(academic_statuses)
      end
      feed
    end

    def roles(statuses)
      roles = role_defaults
      assigned_roles = []

      statuses.each do |status|
        assign_roles(status)
        assigned_roles.concat(collect_roles status)
      end

      assigned_roles.each do |role|
        if roles.has_key?(role)
          roles[role] = true
        end
      end
      roles
    end

    def assign_roles(status)
      career_code = status.try(:[], 'studentCareer').try(:[], 'academicCareer').try(:[], 'code')

      status.try(:[], 'studentPlans').each do |plan|
        if active? plan
          plan_code = plan.try(:[], 'academicPlan').try(:[], 'plan').try(:[], 'code')
          plan[:role] = find_role(plan_code, career_code)
          plan[:enrollmentRole] = find_role(plan_code, career_code, :enrollment)
        end
      end
    end

    def active?(plan)
      plan.try(:[], 'statusInPlan').try(:[], 'status').try(:[], 'code') == 'AC'
    end

    def find_role(plan_code, career_code, enrollment = nil)
      role = get_academic_plan_role_code(plan_code, enrollment) || get_academic_career_role_code(career_code, enrollment)
      role || 'default'
    end

    def collect_roles(status)
      status.try(:[], 'studentPlans').collect do |plan|
        plan[:role]
      end
    end
  end
end

module HubEdos
  class MyAcademicStatus < UserSpecificModel
    include Cache::CachedFeed
    include Cache::UserCacheExpiry
    include Berkeley::AcademicRoles

    def self.get_statuses(uid)
      if response = self.new(uid).get_feed
        parse_academic_statuses(response)
      end
    end

    def self.get_roles(uid)
      if response = self.new(uid).get_feed
        response.try(:[], :feed).try(:[], 'student').try(:[], 'roles')
      end
    end

    def self.get_careers(uid)
      if statuses = self.get_statuses(uid)
        parse_careers(statuses)
      end
    end

    def self.parse_academic_statuses(response)
      response.try(:[], :feed).try(:[], 'student').try(:[], 'academicStatuses')
    end

    def self.parse_careers(statuses)
      [].tap do |careers|
        statuses.each do |status|
          if (career = status['studentCareer'].try(:[], 'academicCareer'))
            careers << career
          end
        end
      end.uniq
    end

    def get_feed_internal
      response = HubEdos::AcademicStatus.new({user_id: @uid}).get
      if (academic_statuses = self.class.parse_academic_statuses(response))
        response[:feed]['student']['roles'] = roles(academic_statuses)
      end
      response
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

    # Beware: roles may be used as a whitelist (to show certain info), a blacklist (to hide certain info),
    #  or as some combination of the two in custom logic.
    def assign_roles(status)
      assign_career_based_role(status.try(:[], 'studentCareer'))
      if plans = status.try(:[], 'studentPlans')
        plans.each do |plan|
          if MyAcademics::AcademicsModule.active? plan
            assign_plan_based_role plan
            assign_program_based_role plan.try(:[], 'academicPlan').try(:[], 'academicProgram')
          end
        end
      end
    end

    def assign_career_based_role(studentCareer)
      if studentCareer
        career_code = studentCareer.try(:[], 'academicCareer').try(:[], 'code')
        studentCareer[:role] = get_academic_career_role_code(career_code)
      end
    end

    def assign_plan_based_role(studentPlan)
      if studentPlan
        plan_code = studentPlan.try(:[], 'academicPlan').try(:[], 'plan').try(:[], 'code')
        studentPlan[:role] = get_academic_plan_role_code(plan_code)
      end
    end

    def assign_program_based_role(studentProgram)
      if studentProgram
        program_code = studentProgram.try(:[], 'program').try(:[], 'code')
        studentProgram[:role] = (get_academic_program_role_code(program_code) || 'default')
      end
    end

    def active?(plan)
      plan.try(:[], 'statusInPlan').try(:[], 'status').try(:[], 'code') == 'AC'
    end

    def collect_roles(status)
      if plans = status.try(:[], 'studentPlans')
        roles = plans.collect do |plan|
          [plan[:role], plan.try(:[], 'academicPlan').try(:[], 'academicProgram').try(:[], :role)]
        end
        roles << status.try(:[], 'studentCareer').try(:[], :role)
        return roles.flatten
      end
      []
    end
  end
end

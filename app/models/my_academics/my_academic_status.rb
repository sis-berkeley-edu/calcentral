module MyAcademics
  class MyAcademicStatus < UserSpecificModel
    include Cache::CachedFeed
    include Cache::UserCacheExpiry
    include Concerns::AcademicRoles

    def self.careers(uid)
      [].tap do |careers|
        self.new(uid).academic_statuses(uid).try(:each) do |status|
          if (career = status['studentCareer'].try(:[], 'academicCareer'))
            careers << career
          end
        end
      end.uniq
    end

    def self.statuses_by_career_role(uid, career_role_matchers = [])
      self.new(uid).academic_statuses(uid).try(:select) do |status|
        role = status.try(:[], 'studentCareer').try(:[], :role)
        career_role_matchers.include?(role)
      end
    end

    def self.has_holds?(uid)
      (self.new(uid).holds.try(:to_a).try(:length) || 0) > 0
    end

    def self.active_plans(uid)
      [].tap do |plans|
        self.new(uid).academic_statuses.try(:each) do |status|
          status.try(:[], 'studentPlans').try(:each) do |plan|
            if (plan.try(:[], 'statusInPlan').try(:[], 'status').try(:[], 'code') == 'AC')
              plan[:careerRole] = status.try(:[], 'studentCareer').try(:[], :role)
              plans.push(plan)
            end
          end
        end
      end
    end

    def self.active_plan?(plan)
      plan.try(:[], 'statusInPlan').try(:[], 'status').try(:[], 'code') == 'AC'
    end

    def get_feed_internal
      response = HubEdos::StudentApi::V2::AcademicStatuses.new(user_id: @uid).get
      statuses = response.try(:[], :feed).try(:[], 'academicStatuses') || []
      if (statuses)
        assign_roles(statuses)
      end
      response
    end

    # Beware: roles may be used as a whitelist (to show certain info), a blacklist
    # (to hide certain info), or as some combination of the two in custom logic.
    def assign_roles(academic_statuses)
      academic_statuses.each do |status|
        process_career(status)
        process_plans(status)
      end
    end

    def process_career(status)
      if (career = status.try(:[], 'studentCareer'))
        status['studentCareer'][:role] = career_based_role career
      end
    end

    def process_plans(status)
      if (plans = status.try(:[], 'studentPlans'))
        plans.each do |plan|
          if self.class.active_plan?(plan)
            # TODO: Update to use :roles
            plan[:role] = plan_based_roles plan
            if (program = plan.try(:[], 'academicPlan').try(:[], 'academicProgram'))
              plan['academicPlan']['academicProgram'][:role] = program_based_role program
            end
          end
        end
      end
    end

    def career_based_role(studentCareer)
      career_code = studentCareer.try(:[], 'academicCareer').try(:[], 'code')
      get_academic_career_roles(career_code).try(:first) if studentCareer
    end

    def plan_based_roles(studentPlan)
      plan_code = studentPlan.try(:[], 'academicPlan').try(:[], 'plan').try(:[], 'code')
      get_academic_plan_roles(plan_code) if studentPlan
    end

    def program_based_role(studentProgram)
      program_code = studentProgram.try(:[], 'program').try(:[], 'code')
      get_academic_program_roles(program_code).try(:first) if studentProgram
    end

    def feed
      get_feed.try(:[], :feed)
    end

    def status_code
      get_feed.try(:[], :statusCode)
    end

    def errored?
      get_feed.try(:[], :errored)
    end

    def error_message
      return get_feed.try(:[], :body) if errored?
      nil
    end

    def academic_statuses
      feed.try(:[], 'academicStatuses')
    end

    def holds
      feed.try(:[], 'holds') || []
    end

    def award_honors
      feed.try(:[], 'awardHonors')
    end

    def degrees
      feed.try(:[], 'degrees')
    end

    def max_terms_in_attendance
      (academic_statuses || []).collect {|s| s['termsInAttendance']}.sort.last
    end
  end
end

module MyAcademics
  class MyAcademicRoles < UserSpecificModel
    include Cache::CachedFeed
    include Cache::UserCacheExpiry
    include Concerns::AcademicRoles

    def get_feed_internal
      {
        current: get_current_roles,
        historical: get_historical_roles,
      }
    end

    def get_current_roles
      current_roles = role_defaults
      map_roles(current_roles, current_term_career_program_and_plan_roles)
      map_roles(current_roles, student_group_roles)
      current_roles
    end

    def student_group_roles
      group_roles = []
      student_group_codes.each do |group_code|
        group_roles << Concerns::AcademicRoles.get_student_group_roles(group_code)
      end
      group_roles.flatten.uniq
    end

    def current_term_plans
      current_term = Berkeley::Terms.fetch.current.try(:campus_solutions_id)
      term_plans.select {|t| t['term_id'].to_s >= current_term.to_s }
    end

    def current_term_career_program_and_plan_roles
      assigned_roles = []
      current_term_plans.each do |term|
        assigned_roles << get_academic_career_roles(term['acad_career'])
        assigned_roles << get_academic_program_roles(term['acad_program'])
        assigned_roles << get_academic_plan_roles(term['acad_plan'])
      end
      assigned_roles.flatten.uniq
    end

    def get_historical_roles
      roles = role_defaults
      assigned_roles = []

      term_plans.each do |term|
        assigned_roles << get_academic_career_roles(term['acad_career'])
        assigned_roles << get_academic_program_roles(term['acad_program'])
        assigned_roles << get_academic_plan_roles(term['acad_plan'])
      end

      map_roles(roles, assigned_roles.flatten.uniq)
      roles
    end

    def map_roles(default_roles, assigned_roles)
      assigned_roles.each do |role|
        if default_roles.has_key?(role)
          default_roles[role] = true
        end
      end
    end

    def term_plans
      @term_plans ||= begin
        user = User::Current.new(@uid)
        User::Academics::TermPlans::TermPlansCached.new(user).get_feed
      end
    end

    def student_group_codes
      @student_group_codes ||= User::Current.new(@uid).student_groups.codes
    end
  end
end

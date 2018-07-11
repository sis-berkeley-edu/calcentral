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
      term_cpp = MyAcademics::MyTermCpp.new(@uid).get_feed
      current_term = Berkeley::Terms.fetch.current.try(:campus_solutions_id)
      current_term_cpp = term_cpp.select {|t| t['term_id'].to_s >= current_term.to_s }
      get_roles(current_term_cpp)
    end

    def get_roles(terms)
      assigned_roles = []
      roles = role_defaults

      terms.each do |term|
        assigned_roles << get_academic_career_roles(term['acad_career'])
        assigned_roles << get_academic_program_roles(term['acad_program'])
        assigned_roles << get_academic_plan_roles(term['acad_plan'])
      end
      assigned_roles.flatten!
      assigned_roles.uniq!

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
  end
end

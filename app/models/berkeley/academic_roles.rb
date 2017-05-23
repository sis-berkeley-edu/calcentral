module Berkeley
  module AcademicRoles
    extend self

    # Role(s) assigned to a user if they are in an academic plan associated with that role.
    ACADEMIC_PLAN_ROLES = [
      {role_code: 'fpf', match: ['25000FPFU'], types: [:enrollment]},
      {role_code: 'haasFullTimeMba', match: ['70141MBAG'], types: [:enrollment]},
      {role_code: 'haasEveningWeekendMba', match: ['701E1MBAG'], types: [:enrollment]},
      {role_code: 'haasExecMba', match: ['70364MBAG'], types: [:enrollment]},
      {role_code: 'haasMastersFinEng', match: ['701F1MFEG'], types: []},
      {role_code: 'haasMbaPublicHealth', match: ['70141BAPHG'], types: []},
      {role_code: 'haasMbaJurisDoctor', match: ['70141BAJDG'], types: []},
      {role_code: 'ugrdUrbanStudies', match: ['19912U'], types: []},
      {
        role_code: 'summerVisitor',
        match: %w(99000U 99000INTU 99000G 99000INTG 99V03U 99V04U 99V05U 99V09U 99V03G 99V05G 99V06G 99V07G 99V08G 99V10G 99V06U 99V07U 99V08U 99V10U 99V02G 99V04G 99V09G),
        types: [:enrollment]
      },
    ]

    # Role(s) assigned to a user if they are in a career associated with that role.
    ACADEMIC_CAREER_ROLES = [
      {role_code: 'ugrd', match: ['UGRD'], types: []},
      {role_code: 'grad', match: ['GRAD'], types: []},
      {role_code: 'law', match: ['LAW'], types: [:enrollment]},
      {role_code: 'concurrent', match: ['UCBX'], types: [:enrollment]}
    ]

    def get_academic_plan_role_code(plan_code, type = nil)
      get_role_code(ACADEMIC_PLAN_ROLES, plan_code, type)
    end

    def get_academic_career_role_code(career_code, type = nil)
      get_role_code(ACADEMIC_CAREER_ROLES, career_code, type)
    end

    def role_defaults
      role_codes.inject({}) { |map, role_code| map[role_code] = false; map }
    end

    private

    def get_role_code(roles, academic_code, type = nil)
      role_codes = roles.select do |matcher|
        is_match = matcher[:match].include?(academic_code)
        is_type = type.blank? || matcher[:types].include?(type.to_sym)
        is_match && is_type
      end
      role_codes.empty? ? nil : role_codes.first[:role_code]
    end

    def role_codes
      (ACADEMIC_PLAN_ROLES | ACADEMIC_CAREER_ROLES).collect do |matcher|
        matcher[:role_code]
      end
    end

  end
end

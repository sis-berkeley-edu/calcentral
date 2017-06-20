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
      {
        role_code: 'courseworkOnly',
        match: %w(00014CWOG 00051CWOG 00059CWOG 00063CWOG 00072CWOG 00086CWOG 00090CWOG 00096CWOG 00101CWOG 00126CWOG 00139CWOG 00168CWOG 00174CWOG 00192CWOG 00213CWOG 00239CWOG 00246CWOG 00270CWOG 002A4CWOG 002A5CWOG 002A6CWOG 002C3CWOG 002C7CWOG 002D0CWOG 002E3CWOG 00345CWOG 00360CWOG 00366CWOG 00368CWOG 00387CWOG 00396CWOG 00408CWOG 00424CWOG 00425CWOG 00428CWOG 00429CWOG 00430CWOG 00469CWOG 00470CWOG 00479CWOG 00482CWOG 00498CWOG 00510CWOG 00531CWOG 00540CWOG 00553CWOG 00570CWOG 00579CWOG 00591CWOG 00592CWOG 00594CWOG 00621CWOG 00651CWOG 00666CWOG 00699CWOG 00780CWOG 00807CWOG 00812CWOG 00838CWOG 00843CWOG 00848CWOG 00849CWOG 00867CWOG 00877CWOG 00882CWOG 00891CWOG 00974CWOG 00975CWOG 009B2CWOG 04034CWOG 04189CWOG 042C5CWOG 04380CWOG 04680CWOG 04683CWOG 04798CWOG 10153CWOG 10294CWOG 16201CWOG 16275CWOG 16288CWOG 16290CWOG 16292CWOG 16295CWOG 16298CWOG 162C8CWOG 16328CWOG 16334CWOG 19084CWOG 19165CWOG 19222CWOG 19489CWOG 194A9CWOG 19920CWOG 30FPFU 70141CWOG 71483CWOG 79249CWOG 79892CWOG 81776CWOG 82790CWOG 86864CWOG 91612CWOG 91613C89G 91935CWOG 96132CWOG 96354CWOG 96357CWOG 96789CWOG),
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

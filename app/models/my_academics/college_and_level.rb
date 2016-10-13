module MyAcademics
  class CollegeAndLevel
    include AcademicsModule
    include ClassLogger
    include User::Student

    # Student Plan Roles represent the type of student based on their student plans
    STUDENT_PLAN_ROLES = {
      plan: [
        {student_plan_role_code: 'fpf', match: '25000FPFU', types: [:enrollment]},
        {student_plan_role_code: 'haasFullTimeMba', match: '70141MBAG', types: []},
        {student_plan_role_code: 'haasEveningWeekendMba', match: '701E1MBAG', types: []},
        {student_plan_role_code: 'haasExecMba', match: '70364MBAG', types: []},
        {student_plan_role_code: 'haasMastersFinEng', match: '701F1MFEG', types: []},
        {student_plan_role_code: 'haasMbaPublicHealth', match: '70141BAPHG', types: []},
        {student_plan_role_code: 'haasMbaJurisDoctor', match: '70141BAJDG', types: []}
      ],
      career: [
        {student_plan_role_code: 'law', match: 'LAW', types: [:enrollment]},
        {student_plan_role_code: 'concurrent', match: 'UCBX', types: [:enrollment]}
      ]
    }

    def self.student_plan_role_codes
      role_codes = []
      STUDENT_PLAN_ROLES.each do |role_category, matchers|
        matchers.each do |matcher|
          role_codes << matcher[:student_plan_role_code]
        end
      end
      role_codes
    end

    def merge(data)
      college_and_level = hub_college_and_level
      if college_and_level[:empty] && !current_term.is_summer
        legacy_college_and_level = bearfacts_college_and_level
        if !legacy_college_and_level[:empty]
          college_and_level = legacy_college_and_level
        end
      end

      # If we have no profile at all, consider the no-profile to be active for the current term.
      if college_and_level[:empty]
        college_and_level[:termName] = Berkeley::Terms.fetch.current.to_english
        college_and_level[:isCurrent] = true
      else
        # The key name is a bit misleading, since the profile might be for a future term.
        # TODO Use this in place of the overly complex 'isProfileCurrent' front-end logic.
        college_and_level[:isCurrent] = !profile_in_past?(college_and_level)
      end
      data[:collegeAndLevel] = college_and_level
    end

    def bearfacts_college_and_level
      response = Bearfacts::Profile.new(user_id: @uid).get
      # response is a pointer to an obj in memory and should not be modified, other functions may need to use it later
      result = response.clone
      feed = result.delete :feed
      # The Bear Facts API can return empty profiles if the user is no longer (or not yet) considered an active student.
      # Partial profiles can be returned for incoming students around the start of the term.
      if (feed.nil? || feed['studentProfile']['studentGeneralProfile'].blank? || feed['studentProfile']['ugGradFlag'].blank?)
        result[:empty] = true
      else
        result.merge! parse_bearfacts_feed(feed)
      end
      result
    end

    def hub_college_and_level
      # academic_status is a pointer to an obj in memory and should not be modified, other functions may need to use it later
      academic_status = get_academic_status.clone
      if (holds = parse_hub_holds academic_status)
        academic_status[:holds] = holds
      end
      if (statuses = parse_hub_academic_statuses academic_status)
        status = statuses.first
        academic_status[:careers] = parse_hub_careers statuses
        academic_status[:level] = parse_hub_level statuses
        academic_status[:termName] = parse_hub_term_name(status['currentRegistration'].try(:[], 'term')).try(:[], 'name')
        academic_status[:termsInAttendance] = status['termsInAttendance'].to_s
        academic_status.merge! parse_hub_plans statuses
      else
        academic_status[:empty] = true
      end
      academic_status.delete(:feed)
      academic_status
    end

    def parse_hub_holds(response)
      holds = {hasHolds: false}
      holds_feed = response[:feed] && response[:feed]['student'] && response[:feed]['student']['holds']
      if holds_feed.present?
        holds[:hasHolds] = true if holds_feed.to_a.length > 0
      end
      holds
    end

    def parse_hub_careers(statuses)
      [].tap do |careers|
        statuses.each do |status|
          if (career = status['studentCareer'].try(:[], 'academicCareer').try(:[], 'description'))
            careers << career
          end
        end
      end.uniq.compact
    end

    def parse_hub_level(statuses)
      level = statuses.collect do |status|
        status['currentRegistration'].try(:[], 'academicLevel').try(:[], 'level').try(:[], 'description')
      end.uniq.compact.to_sentence
      level.blank? ? nil : level
    end

    def parse_hub_plans(statuses)
      plan_set = {
        majors: [],
        minors: [],
        plans: [],
        lastExpectedGraduationTerm: { code: nil, name: nil },
        roles: role_booleans
      }

      filtered_statuses = filter_inactive_status_plans(statuses)
      active_statuses = active_academic_statuses(filtered_statuses)

      active_statuses.each do |status|
        Array.wrap(status.try(:[], 'studentPlans')).each do |plan|
          flattened_plan = flatten_plan(plan)
          plan_set[:plans] << flattened_plan

          # Catch Majors / Minors
          college_plan = {college: flattened_plan[:college]}
          case flattened_plan[:type].try(:[], :category)
            when 'Major'
              plan_set[:majors] << college_plan.merge({
                major: flattened_plan[:plan].try(:[], :description)
              })
            when 'Minor'
              plan_set[:minors] << college_plan.merge({
                minor: flattened_plan[:plan].try(:[], :description)
              })
          end

          # Update Roles
          current_role = flattened_plan.try(:[], :role)
          if plan_set[:roles].has_key?(current_role)
            plan_set[:roles][current_role] = true
          end

          # Catch Last Expected Graduation Date
          if (plan_set[:lastExpectedGraduationTerm].try(:[], :code).to_i < flattened_plan[:expectedGraduationTerm].try(:[], :code).to_i)
            plan_set[:lastExpectedGraduationTerm] = flattened_plan[:expectedGraduationTerm]
          end
        end
      end
      plan_set
    end

    def filter_inactive_status_plans(statuses)
      statuses.each do |status|
        status['studentPlans'].select! do |plan|
          plan.try(:[], 'statusInPlan').try(:[], 'status').try(:[], 'code') == 'AC'
        end
      end
      statuses
    end

    def active_academic_statuses(statuses)
      active_statuses = statuses.select do |status|
        status.try(:[], 'studentPlans').try(:count).to_i > 0
      end
      active_statuses
    end

    def parse_hub_term_name(term)
      if term
        term['name'] = Berkeley::TermCodes.normalized_english term.try(:[], 'name')
      end
      term
    end

    def parse_bearfacts_feed(feed)
      careers = []
      ug_grad_flag = feed['studentProfile']['ugGradFlag'].to_text
      case ug_grad_flag.upcase
        when 'U'
          careers << 'Undergraduate'
        when 'G'
          careers << 'Graduate'
        else
          logger.error("Unknown ugGradFlag '#{ug_grad_flag}' for user #{@uid}")
          return {}
      end

      general_profile = feed['studentProfile']['studentGeneralProfile']

      level = general_profile['corpEducLevel'].to_text.titleize
      nonAPLevel = general_profile['nonAPLevel'].to_text.titleize
      futureTBLevel = general_profile['futureTBLevel'].to_text.titleize

      majors = []
      primary_college_abbv = general_profile['collegePrimary'].to_text
      primary_college = Berkeley::Colleges.get(primary_college_abbv)
      primary_major = Berkeley::Majors.get(general_profile['majorPrimary'].to_text)

      # this code block is not very DRY, but that makes it easier to understand the wacky requirements. See CLC-2017 for background.
      if primary_college_abbv.in?(['GRAD DIV', 'LAW', 'CONCURNT'])
        if primary_major == 'Double' || primary_major == 'Triple'
          majors << {
            college: (general_profile['collegeSecond'].blank? ? primary_college : Berkeley::Colleges.get(general_profile['collegeSecond'].to_text)),
            major: Berkeley::Majors.get(general_profile['majorSecond'].to_text)
          }
          majors << {
            college: Berkeley::Colleges.get(general_profile['collegeThird'].to_text),
            major: Berkeley::Majors.get(general_profile['majorThird'].to_text)
          }
          if primary_major == 'Triple'
            majors << {
              college: Berkeley::Colleges.get(general_profile['collegeFourth'].to_text),
              major: Berkeley::Majors.get(general_profile['majorFourth'].to_text)
            }
          end
        else
          majors << {
            college: primary_college,
            major: primary_major
          }
        end
      else
        if primary_major == 'Double' || primary_major == 'Triple'
          majors << {
            college: primary_college,
            major: Berkeley::Majors.get(general_profile['majorSecond'].to_text)
          }
          majors << {
            college: '',
            major: Berkeley::Majors.get(general_profile['majorThird'].to_text)
          }
          if primary_major == 'Triple'
            majors << {
              college: '',
              major: Berkeley::Majors.get(general_profile['majorFourth'].to_text)
            }
          end
        else
          majors << {
            college: primary_college,
            major: primary_major
          }
        end
      end
      term_name = "#{feed['studentProfile']['termName'].to_text} #{feed['studentProfile']['termYear'].to_text}"
      feed = {
        careers: careers,
        level: level,
        futureTelebearsLevel: futureTBLevel,
        majors: majors,
        termName: term_name
      }
      feed[:nonApLevel] = nonAPLevel if nonAPLevel.present? && nonAPLevel != level
      feed
    end

    def get_academic_status
      @academic_status ||= HubEdos::AcademicStatus.new({user_id: @uid}).get
    end

    def flatten_plan(hub_plan)
      flat_plan = {
        career: {},
        program: {},
        plan: {},
      }
      if (academic_plan = hub_plan['academicPlan'])
        # Get CPP
        academic_program = academic_plan.try(:[], 'academicProgram')
        career = academic_program.try(:[], 'academicCareer')
        program = academic_program.try(:[], 'program')
        plan = academic_plan.try(:[], 'plan')

        # Extract CPP
        flat_plan[:career].merge!({
          code: career.try(:[], 'code'),
          description: career.try(:[], 'description')
        })
        flat_plan[:program].merge!({
          code: program.try(:[], 'code'),
          description: program.try(:[], 'description')
        })
        flat_plan[:plan].merge!({
          code: plan.try(:[], 'code'),
          description: plan.try(:[], 'description')
        })

        if (hub_plan['expectedGraduationTerm'])
          expected_grad_term_name = hub_plan['expectedGraduationTerm'].try(:[], 'name')
          flat_plan[:expectedGraduationTerm] = {
            code: hub_plan['expectedGraduationTerm'].try(:[], 'id'),
            name: Berkeley::TermCodes.normalized_english(expected_grad_term_name)
          }
        end
        flat_plan[:role] = get_student_plan_role_code(flat_plan)
        flat_plan[:enrollmentRole] = get_student_plan_role_code(flat_plan, :enrollment)
        flat_plan[:primary] = !!hub_plan['primary']
        flat_plan[:type] = categorize_plan_type(academic_plan['type'])

        # TODO: Need to re-evaluate the proper field for college name. See adminOwners
        flat_plan[:college] = academic_plan['academicProgram'].try(:[], 'program').try(:[], 'description')
      end
      flat_plan
    end

    def role_booleans
      self.class.student_plan_role_codes.inject({}) { |map, role_code| map[role_code] = false; map }
    end

    # Designates CalCentral specific plan role (e.g. 'default', 'law', 'fpf', etc.)
    def get_student_plan_role_code(plan, type = nil)
      role_codes = []
      STUDENT_PLAN_ROLES.each do |cpp_category, matchers|
        category_role_codes = matchers.select do |matcher|
          category_code_match = plan[cpp_category][:code] == matcher[:match]
          type_match = type.nil? || matcher[:types].include?(type.to_sym)
          category_code_match && type_match
        end
        role_codes.concat(category_role_codes)
      end
      role_codes.empty? ? 'default' : role_codes.first[:student_plan_role_code]
    end

    def categorize_plan_type(type)
      case type.try(:[], 'code')
        when 'MAJ', 'SS', 'SP', 'HS', 'CRT'
          category = 'Major'
        when 'MIN'
          category = 'Minor'
      end
      {
        code: type['code'],
        description: type['description'],
        category: category
      }
    end

    def profile_in_past?(profile)
      if !profile[:empty] && (term = Berkeley::TermCodes.from_english profile[:termName])
        time_bucket(term[:term_yr], term[:term_cd]) == 'past'
      else
        false
      end
    end
  end
end

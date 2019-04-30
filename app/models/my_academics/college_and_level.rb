module MyAcademics
  class CollegeAndLevel < UserSpecificModel
    include ClassLogger
    include DatedFeed
    include Concerns::AcademicStatus

    CS_DATE_FORMAT = "%Y-%m-%d"

    def merge(data)
      college_and_level = hub_college_and_level

      # If we have no profile at all, consider the no-profile to be active for the current term.
      if college_and_level[:empty]
        college_and_level[:termName] = Berkeley::Terms.fetch.current.try(:to_english)
        college_and_level[:isCurrent] = true
      else
        # The key name is a bit misleading, since the profile might be for a future term.
        college_and_level[:isCurrent] = !profile_in_past?(college_and_level)
      end
      data[:collegeAndLevel] = college_and_level
    end

    def hub_college_and_level
      hub_response = MyAcademics::MyAcademicStatus.new(@uid).get_feed
      hub_student = HubEdos::Student.new(@uid)
      college_and_level = {
        holds: parse_hub_holds(hub_response),
        awardHonors: parse_hub_award_honors(hub_response),
        roles: parse_hub_roles(hub_response),
        statusCode: hub_response.try(:[], :statusCode),
        errored: hub_response.try(:[], :errored),
        body: hub_response.try(:[], :body)
      }

      statuses = academic_statuses hub_response
      if (status = statuses.first)
        registration_term = status.try(:[], 'currentRegistration').try(:[], 'term')
        college_and_level[:careers] = parse_hub_careers statuses
        college_and_level[:level] = hub_student.student_academic_level
        college_and_level[:termName] = parse_hub_term_name(registration_term).try(:[], 'name')
        college_and_level[:termId] = registration_term.try(:[], 'id')
        college_and_level[:termsInAttendance] = status.try(:[], 'termsInAttendance').try(:to_s)
        college_and_level.merge! parse_hub_plans statuses
        college_and_level[:degrees] = parse_hub_degrees hub_response
      else
        college_and_level[:empty] = true
      end
      college_and_level[:termsInAttendance] = hub_student.max_terms_in_attendance.to_s
      college_and_level
    end

    def parse_hub_holds(response)
      {
        hasHolds: has_holds?(response)
      }
    end

    def parse_hub_award_honors(response)
      honors = sort_award_honors response.try(:[], :feed).try(:[], 'student').try(:[], 'awardHonors')
      honors_by_term = {}
      honors.try(:each) do |honor|
        term_id = honor.try(:[], 'term').try(:[], 'id')
        honors_by_term[term_id] ||= []
        honors_by_term[term_id] << {
          awardDate: parse_date(honor.try(:[], 'awardDate')),
          code: honor.try(:[], 'type').try(:[], 'code'),
          description: honor.try(:[], 'type').try(:[], 'description')
        }
      end
      honors_by_term
    end

    def sort_award_honors(honors)
      honors.try(:sort_by) do |honor|
        honor.try(:[], 'term').try(:[], 'id').to_s
      end.try(:reverse)
    end

    def parse_date(date)
      pretty_date = ''
      begin
        pretty_date = format_date(strptime_in_time_zone(date, CS_DATE_FORMAT), '%b %d, %Y')[:dateString] unless date.blank?
      rescue => e
        logger.error "Error parsing date: #{date} for uid = #{@uid}; caused by: #{e}"
      end
      pretty_date
    end

    def parse_hub_roles(response)
      response.try(:[], :feed).try(:[], 'student').try(:[], 'roles')
    end

    def parse_hub_careers(statuses)
      careers = careers(statuses)
      careers.collect {|career| career.try(:[], 'description') }.uniq
    end

    def parse_hub_plans(statuses)
      plan_set = {
        majors: [],
        minors: [],
        designatedEmphases: [],
        plans: []
      }

      filtered_statuses = filter_inactive_status_plans(statuses)

      filtered_statuses.each do |status|
        Array.wrap(status.try(:[], 'studentPlans')).each do |plan|
          flattened_plan = flatten_plan(plan.try(:[], 'academicPlan'))
          add_sub_plan(flattened_plan, plan)
          add_expected_graduation_term(flattened_plan, plan)

          # TODO: Need to re-evaluate the proper field for college name. See adminOwners
          flattened_plan[:college] = plan.try(:[], 'academicPlan').try(:[], 'academicProgram').try(:[], 'program').try(:[], 'description')
          flattened_plan[:role] = plan[:role]
          flattened_plan[:primary] = !!plan['primary']

          plan_set[:plans] << flattened_plan
          group_plans_by_type(plan_set, flattened_plan)
        end
      end
      plan_set
    end

    def parse_hub_degrees(response)
      if (degrees = response.try(:[], :feed).try(:[], 'student').try(:[], 'degrees'))
        awarded_degrees = []
        degrees.each do |degree|
          if degree.try(:[], 'status').try(:[], 'code') == 'Awarded'
            plan_set = {
              majors: [],
              minors: [],
              designatedEmphases: [],
              plans: []
            }
            degree.try(:[], 'academicPlans').try(:each) do |academic_plan|
              flattened_plan = flatten_plan(academic_plan)
              flattened_plan[:college] = academic_plan.try(:[], 'academicProgram').try(:[], 'academicGroup').try(:[], 'formalDescription')
              plan_set[:plans] << flattened_plan
              group_plans_by_type(plan_set, flattened_plan)
            end

            degree.merge! plan_set
            degree[:isUndergrad] = :UGRD == degree[:plans].try(:first).try(:[], :career).try(:[], :code).try(:intern)
            awarded_degrees << degree
          end
        end
        awarded_degrees unless awarded_degrees.empty?
      end
    end

    def group_plans_by_type(plan_set, plan)
      college_plan = {college: plan[:college]}
      case plan[:type].try(:[], :category)
        when 'Major'
          plan_set[:majors] << college_plan.merge({
            major: plan.try(:[], :plan).try(:[], :description),
            description: plan.try(:[], :plan).try(:[], :formalDescription),
            subPlan: plan.try(:[], :subPlan).try(:[], :description),
            type: plan.try(:[], :type).try(:[], :code)
          })
        when 'Minor'
          plan_set[:minors] << college_plan.merge({
            minor: plan.try(:[], :plan).try(:[], :description),
            description: plan.try(:[], :plan).try(:[], :formalDescription),
            subPlan: plan.try(:[], :subPlan).try(:[], :description),
            type: plan.try(:[], :type).try(:[], :code)
          })
        when 'Designated Emphasis'
          plan_set[:designatedEmphases] << college_plan.merge({
            designatedEmphasis: plan.try(:[], :plan).try(:[], :description),
            description: plan.try(:[], :plan).try(:[], :formalDescription),
            subPlan: plan.try(:[], :subPlan).try(:[], :description),
            type: plan.try(:[], :type).try(:[], :code)
          })
      end
    end

    def filter_inactive_status_plans(statuses)
      statuses.each do |status|
        status['studentPlans'].select! do |plan|
          active? plan
        end
      end
      statuses
    end

    def parse_hub_term_name(term)
      if term
        term['name'] = Berkeley::TermCodes.normalized_english term.try(:[], 'name')
      end
      term
    end

    def flatten_plan(hub_plan)
      flat_plan = {
        career: {},
        program: {},
        plan: {},
        subPlan: {}
      }
      if (hub_plan)
        academic_program = hub_plan.try(:[], 'academicProgram')
        career = academic_program.try(:[], 'academicCareer')
        program = academic_program.try(:[], 'program')
        plan = hub_plan.try(:[], 'plan')

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
          description: plan.try(:[], 'description'),
          formalDescription: plan.try(:[], 'formalDescription')
        })

        flat_plan[:type] = categorize_plan_type(hub_plan.try(:[], 'type'))
      end
      flat_plan
    end

    def add_sub_plan(flattened_plan, plan)
      if (academic_sub_plan = plan.try(:[], 'academicSubPlan'))
        sub_plan = academic_sub_plan.try(:[], 'subPlan')
        flattened_plan[:subPlan].merge!({
          code: sub_plan.try(:[], 'code'),
          description: sub_plan.try(:[], 'description')
        })
      end
    end

    def add_expected_graduation_term(flattened_plan, plan)
      if (expected_graduation_term = plan.try(:[], 'expectedGraduationTerm'))
        expected_grad_term_name = expected_graduation_term.try(:[], 'name')
        flattened_plan[:expectedGraduationTerm] = {
          code: expected_graduation_term.try(:[], 'id'),
          name: Berkeley::TermCodes.normalized_english(expected_grad_term_name)
        }
      end
    end

    def categorize_plan_type(type)
      case (code = type.try(:[], 'code'))
        when 'MAJ', 'SS', 'SP', 'HS', 'CRT'
          category = 'Major'
        when 'MIN'
          category = 'Minor'
        when 'DE'
          category = 'Designated Emphasis'
      end
      {
        code: code,
        description: type.try(:[], 'description'),
        category: category
      }
    end

    def profile_in_past?(profile)
      if !profile[:empty] && (term = Berkeley::TermCodes.from_english profile[:termName])
        Concerns::AcademicsModule.time_bucket(term[:term_yr], term[:term_cd]) == 'past'
      else
        false
      end
    end
  end
end

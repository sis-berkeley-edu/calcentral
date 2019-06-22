module MyAcademics
  class Graduation < UserSpecificModel
    require 'set'
    include Cache::CachedFeed
    include Cache::UserCacheExpiry
    include ClassLogger
    include Concerns::AcademicStatus
    include User::Identifiers

    def merge(data)
      data[:graduation] = get_feed
      data
    end

    def get_feed_internal
      return {} unless HubEdos::UserAttributes.new(user_id: @uid).has_role?(:student) && hub_statuses.present?
      terms_with_appts = nil
      appts_in_graduating_term = nil
      ugrd_grad_term = extract_latest_undergraduate_graduation_term
      show_graduation_checklist = false
      if ugrd_grad_term.present?
        terms_with_appts = active_terms_with_enrollment_appointments
        appts_in_graduating_term = appointments_in_graduating_term(ugrd_grad_term, terms_with_appts)
        show_graduation_checklist = ['EG', 'AP', 'AW'].include?(ugrd_grad_term[:degreeCheckoutStatus])
      end
      required_message = CampusSolutions::MessageCatalog.get_message(:graduation_required)
      with_loans_message = CampusSolutions::MessageCatalog.get_message(:graduation_with_loans)
      recommended_message = CampusSolutions::MessageCatalog.get_message(:graduation_recommended)
      {
        undergraduate: {
          expectedGraduationTerm: ugrd_grad_term,
          showGraduationChecklist: show_graduation_checklist,
          activeTermsWithEnrollmentAppointments: terms_with_appts,
          appointmentsInGraduatingTerm: appts_in_graduating_term,
          messages: {
            required: required_message.try(:[], :descrlong),
            studentsWithLoans: with_loans_message.try(:[], :descrlong),
            recommended: recommended_message.try(:[], :descrlong)
          }
        },
        gradLaw: {
          expectedGraduationTerms: extract_non_undergraduate_graduation_terms
        }
      }
    end

    def active_terms_with_enrollment_appointments
      if terms = CampusSolutions::MyEnrollmentTerms.get_terms(@uid)
        term_ids = terms.collect {|t| t.try(:[], :termId) }.compact
        term_ids.select do |term_id|
          term_details = CampusSolutions::MyEnrollmentTerm.get_term(@uid, term_id)
          term_details[:enrollmentPeriod].any?
        end
      end
    end

    def appointments_in_graduating_term(last_expected_graduation_term, terms_with_appointments)
      term_code = last_expected_graduation_term.try(:[], :termId)
      terms_with_appointments.include?(term_code)
    end

    def is_concurrent_student
      @is_concurrent_student ||= EdoOracle::Student.new(user_id: @uid).concurrent?
    end

    def extract_latest_undergraduate_graduation_term
      ugrd_statuses = all_undergraduate_statuses hub_statuses
      return nil if ugrd_statuses.empty?

      plans = active_plans_from_statuses(ugrd_statuses)
      return nil if plans.empty?

      if plans.length > 1
        plan_with_latest_grad_term = plans.try(:max) do |a, b|
          a.try(:[], 'expectedGraduationTerm').try(:[], 'id') <=> b.try(:[], 'expectedGraduationTerm').try(:[], 'id')
        end
      else
        plan_with_latest_grad_term = plans.try(:first)
      end
      {
        degreeCheckoutStatus: plan_with_latest_grad_term.try(:[], 'degreeCheckoutStatus').try(:[], 'code'),
        termId: plan_with_latest_grad_term.try(:[], 'expectedGraduationTerm').try(:[], 'id'),
        termName: Berkeley::TermCodes.normalized_english(plan_with_latest_grad_term.try(:[], 'expectedGraduationTerm').try(:[], 'name'))
      }
    end

    def extract_non_undergraduate_graduation_terms
      non_ugrd_statuses = all_grad_law_statuses hub_statuses
      return nil if non_ugrd_statuses.empty?

      if non_ugrd_statuses.length >= 1
        # CalCentral only shows expected graduation for GRAD careers if the student has concurrent status
        non_ugrd_statuses = is_concurrent_student ? non_ugrd_statuses : all_law_statuses(non_ugrd_statuses)
      end

      plans = active_plans_from_statuses non_ugrd_statuses
      return nil if plans.empty?

      sort_plans_by_program plans
    end

    def sort_plans_by_program(plans)
      parsed_program_codes = []
      parsed_plans = []
      plans.try(:each) do |plan|
        program_code = plan.try(:[], 'academicPlan').try(:[], 'academicProgram').try(:[], 'program').try(:[], 'code')
        plan_description = plan.try(:[], 'academicPlan').try(:[], 'plan').try(:[], 'description')
        expected_grad_term_id = plan.try(:[], 'expectedGraduationTerm').try(:[], 'id')
        expected_grad_term_name = Berkeley::TermCodes.normalized_english(plan.try(:[], 'expectedGraduationTerm').try(:[], 'name'))

        if parsed_program_codes.include? program_code
          related_plan_index = parsed_plans.try(:find_index) do |parsed_plan|
            parsed_plan.try(:[], :program) == program_code
          end
          if related_plan_index.present? && related_plan = parsed_plans[related_plan_index]
            related_plan[:plans].push plan_description
            # Each plan under the same program should have the same expected graduation term, but if there is a conflict, log it and surface both expected grad terms
            unless related_plan[:expectedGradTermIds].include? expected_grad_term_id
              logger.warn("UID #{@uid} has conflicting expected graduation terms under the #{program_code} program")
              related_plan[:expectedGradTermIds].push expected_grad_term_id
              related_plan[:expectedGradTermNames].push expected_grad_term_name
            end
          end
        else
          parsed_program_codes.push program_code
          parsed_plans.push(
            {
              program: program_code,
              plans: Array.wrap(plan_description),
              expectedGradTermIds: Array.wrap(expected_grad_term_id),
              expectedGradTermNames: Array.wrap(expected_grad_term_name)
            })
        end
      end
      parsed_plans
    end

    def hub_statuses
      @statuses ||= academic_statuses MyAcademics::MyAcademicStatus.new(@uid).get_feed
    end

  end
end

module MyAcademics
  class Graduation < UserSpecificModel
    require 'set'
    include Cache::CachedFeed
    include Cache::UserCacheExpiry
    include AcademicsModule

    def merge(data)
      data[:graduation] = get_feed
      data
    end

    def get_feed_internal
      return {} unless HubEdos::UserAttributes.new(user_id: @uid).has_role?(:student)
      exp_grad_term = last_expected_graduation_term
      terms_with_appts = active_terms_with_enrollment_appointments
      HashConverter.camelize({
        lastExpectedGraduationTerm: exp_grad_term,
        activeTermsWithEnrollmentAppointments: terms_with_appts,
        isNotGraduateOrLawStudent: isNotGraduateOrLawStudent,
        appointmentsInGraduatingTerm: appointmentsInGraduatingTerm(exp_grad_term, terms_with_appts),
      })
    end

    def last_expected_graduation_term
      expected_graduation_term = { code: nil, name: nil }
      if (statuses = HubEdos::MyAcademicStatus.get_statuses(@uid))
        statuses.each do |status|
          Array.wrap(status.try(:[], 'studentPlans')).each do |plan|
            current_expected_graduation_term = get_expected_graduation_term(plan) if MyAcademics::AcademicsModule.active? plan

            # Catch Last Expected Graduation Date
            if (expected_graduation_term.try(:[], :code).to_i < current_expected_graduation_term.try(:[], :code).to_i)
              expected_graduation_term = current_expected_graduation_term
            end
          end
        end
      end
      expected_graduation_term
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

    def get_expected_graduation_term(plan)
      if expected_graduation_term = plan.try(:[], 'expectedGraduationTerm')
        term_id = expected_graduation_term.try(:[], 'id')
        term_name = expected_graduation_term.try(:[], 'name')
        {
          code: term_id,
          name: Berkeley::TermCodes.normalized_english(term_name)
        }
      end
    end

    def isNotGraduateOrLawStudent
      if (careers = HubEdos::MyAcademicStatus.get_careers(@uid))
        codes = careers.map { |c| c.try(:[], 'code') }
        intersection = codes.to_set.intersection(Set['GRAD', 'LAW'])
        return intersection.length == 0
      end
      false
    end

    def appointmentsInGraduatingTerm(last_expected_graduation_term, terms_with_appointments)
      term_code = last_expected_graduation_term.try(:[], :code)
      terms_with_appointments.include?(term_code)
    end
  end
end

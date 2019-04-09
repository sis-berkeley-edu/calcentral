module MyRegistrations
  module RegistrationsModule
    extend self

    include SharedHelpers

    GRAD_SUMMARIES = {
      activeRegistered: 'You have access to campus services.',
      feesUnpaid:       'Fees Unpaid',
      hasHold:          'You may not have access to campus services due to a hold. Please address your holds to become entitled to campus services.',
      notEnrolled:      'Not Enrolled'
    }
    PRIORITIZED_GRAD_SUMMARIES = [
      GRAD_SUMMARIES[:feesUnpaid],
      GRAD_SUMMARIES[:hasHold],
      GRAD_SUMMARIES[:activeRegistered],
      GRAD_SUMMARIES[:notEnrolled]
    ]

    def match_positive_indicators(positive_indicators, term_registrations)
      # Create a clone of the positive service indicators array, since we'll be altering it.
      pos_indicators = positive_indicators.clone
      indicator_map = {}.tap do |map|
        pos_indicators.each do |indicator|
          indicator_term = indicator['fromTerm']['id']
          if map.has_key?(indicator_term)
            map[indicator_term].push(indicator)
          else
            map[indicator_term] = [indicator]
          end
        end
      end

      term_registrations.each do |term_id, reg_array|
        reg_array.each { |reg| reg[:positiveIndicators] = indicator_map.has_key?(term_id) ? indicator_map[term_id]: [] }
      end

      term_registrations
    end

    def is_positive_service_indicator?(attribute)
      attribute.try(:[], 'type').try(:[], 'code').try(:start_with?, '+')
    end

    def check_indicator_dates(indicator)
      term_start = indicator.try(:[], 'fromTerm').try(:[], 'id').to_i
      term_end = indicator.try(:[], 'toTerm').try(:[], 'id').to_i
      if term_start != term_end
        indicator_type = indicator.try(:[], 'type').try(:[], 'code')
        logger.warn "Positive service indicator spanning multiple terms found.  Indicator: #{indicator_type}, termStart ID: #{term_start}, termEnd ID: #{term_end}. Using termStart ID to parse registration status."
      end
    end

    def filter_invalid_registrations(term_registrations)
      term_registrations.each do |term_id, reg_array|
        reg_array.delete_if { |reg| !valid_registration?(reg) }
      end
      term_registrations.delete_if { |term, registrations| registrations.empty? }
    end

    def valid_registration?(registration)
      past_end_of_instruction = get_term_flag(registration, :pastEndOfInstruction)
      term_career = get_term_career(registration)
      term_includes_indicator?(registration, '+S09') && !past_end_of_instruction && (term_career != CAREERS[:extension])
    end

    def set_reg_messaging(term_registrations)
      term_registrations.each do |term_id, reg_array|
        reg_array.each do |reg|
          is_undergrad = get_term_career(reg) == CAREERS[:undergrad]
          is_active = term_includes_indicator?(reg, '+REG')
          registration_details = {
            isActive: is_active,
            message: is_active ? extract_indicator_message(reg, '+REG') : nil
          }

          summary = is_undergrad ? set_reg_summary_undergrad(reg, registration_details) : set_reg_summary_grad(reg, registration_details)
          reg[:regStatus] = {
            summary: summary,
            explanation: is_undergrad ? set_reg_explanation_undergrad(reg, summary, registration_details) : set_reg_explanation_grad(summary)
          }
        end
      end
      term_registrations
    end

    def set_reg_summary_undergrad(term, registered)
      if enrolled? term
        return registered[:isActive] ? UGRD_SUMMARIES[:registered] : UGRD_SUMMARIES[:notRegistered]
      else
        return UGRD_SUMMARIES[:notEnrolled]
      end
    end

    def set_reg_summary_grad(term, registered)
      enrolled = enrolled?(term)
      has_r99_sf20 = term_includes_r99_sf20?(term)
      if enrolled
        if registered[:isActive]
          summary = GRAD_SUMMARIES[:activeRegistered]
        else
          if has_r99_sf20
            summary = GRAD_SUMMARIES[:hasHold]
          else
            summary = GRAD_SUMMARIES[:feesUnpaid]
          end
        end
      else
        summary = GRAD_SUMMARIES[:notEnrolled]
      end
      summary
    end

    def set_reg_explanation_undergrad(term, summary, registered)
      summer = term.try(:[], :isSummer)
      case summary
      when UGRD_SUMMARIES[:registered]
        return summer ? reg_explanations[:registeredSummerUgrd] : registered[:message]
      when UGRD_SUMMARIES[:notRegistered]
        return summer ? reg_explanations[:notRegisteredSummerUgrd] : reg_explanations[:notOfficiallyRegistered]
      when UGRD_SUMMARIES[:notEnrolled]
        return reg_explanations[:notEnrolledUndergrad]
      end
    end

    def set_reg_explanation_grad(summary)
      case summary
      when GRAD_SUMMARIES[:feesUnpaid]
        return reg_explanations[:feesUnpaidGrad]
      when GRAD_SUMMARIES[:notEnrolled]
        return reg_explanations[:notEnrolledGrad]
      else
        return nil
      end
    end

    def reduce_term_registrations(term_registrations)
      term_registrations.transform_values! do |reg_array|
        reg_array.length > 1 ? filter_by_career(reg_array) : reg_array.first
      end
    end

    def filter_by_career(reg_array)
      career_map = reg_array.map { |reg| [get_term_career(reg), reg] }.to_h

      if career_map.has_key?(CAREERS[:law]) || career_map.has_key?(CAREERS[:grad])
        filtered_map = career_map.reject { |career, reg| career == CAREERS[:undergrad] || career == CAREERS[:extension] }
      else
        filtered_map = career_map.reject { |career, reg| career == CAREERS[:extension] }
      end

      # if we still have more than one career, further filter by registration summary
      # otherwise, return the relevant career
      filtered_map.length > 1 ? filter_by_reg_summary(filtered_map.values) : filtered_map.values.first
    end

    def filter_by_reg_summary(reg_array)
      # iterate through the ordered array of registration summaries, and return the first one that matches our reg object
      PRIORITIZED_GRAD_SUMMARIES.each do |summary|
        if (match = reg_array.find { |reg|  reg[:regStatus][:summary] == summary })
          break match
        end
      end
    end

    def enrolled?(term)
      term_units = term.try(:[], 'termUnits').find do |units|
        units.try(:[], 'type').try(:[], 'description') == 'Total'
      end
      enrolled_units = term_units.try(:[], 'unitsEnrolled')
      taken_units = term_units.try(:[], 'unitsTaken')
      (!enrolled_units.nil? && enrolled_units != 0) || (!taken_units.nil? && taken_units != 0)
    end

    # Graduate students receive R99 service indicators, but it's only related to their registration status if it has a reason code of 'SF20%'
    def term_includes_r99_sf20?(term)
      !!term.try(:[], :positiveIndicators).find do |indicator|
        indicator.try(:[], 'type').try(:[], 'code') == '+R99' && indicator.try(:[], 'reason').try(:[], 'code') == 'SF20%'
      end
    end

  end
end

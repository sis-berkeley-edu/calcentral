module MyRegistrations
  module RegistrationsModule
    extend self

    include Berkeley::TermCodes

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

    # If a student is activated for more than one career within a term, we prioritize the careers
    # and only show the most relevant one.  Prioritization of careers follows the pattern of LAW -> GRAD -> UGRD
    def find_relevant_career(registrations)
      if registrations.length > 1
        find_law_career(registrations)
      # If there is only one registration for the term, return that registration hash.
      elsif registrations.length == 1
        registrations[0]
      # And lastly, if there are no registrations at all, return nil.
      else
        nil
      end
    end

    def find_law_career(registrations)
      registrations.find(find_grad_career registrations) do |registration|
        registration.try(:[], 'academicCareer').try(:[], 'code') == 'LAW'
      end
    end

    def find_grad_career(registrations)
      registrations.find(find_undergrad_career registrations) do |registration|
        registration.try(:[], 'academicCareer').try(:[], 'code') == 'GRAD'
      end
    end

    def find_undergrad_career(registrations)
      registrations.find do |registration|
        registration.try(:[], 'academicCareer').try(:[], 'code') == 'UGRD'
      end
    end

    def set_regstatus_flags(term_registrations)
      term_registrations.each do |term_id, term_value|
        term_value[:showRegStatus] = show_regstatus? term_value
      end
    end

    def set_summer_flags(term_registrations)
      term_registrations.each do |term_id, term_value|
        term_value[:isSummer] = edo_id_is_summer?(term_id)
      end
    end

    def set_regstatus_messaging(term_registrations)
      term_registrations.each do |term_id, term_value|
        show_regstatus = term_value.try(:[], :showRegStatus)

        if show_regstatus
          undergrad = term_value.try(:[], 'academicCareer').try(:[], 'code') == 'UGRD'
          registered = {isActive: term_includes_indicator?(term_value, '+REG')}
          registered.merge!({message: extract_indicator_message(term_value, '+REG')}) if registered[:isActive]

          regstatus_summary = undergrad ? set_regstatus_summary_undergrad(term_value, registered) : set_regstatus_summary_grad(term_value, registered)
          term_value[:regStatus] = {
            summary: regstatus_summary,
            explanation: undergrad ? set_regstatus_explanation_undergrad(term_value, regstatus_summary, registered) : set_regstatus_explanation_grad(term_value, regstatus_summary)
          }
        end
      end
    end

    def set_regstatus_summary_grad(term, registered)
      enrolled = enrolled?(term)
      has_r99_sf20 = term_includes_r99_sf20?(term)
      if enrolled
        if registered[:isActive]
          summary = 'You have access to campus services.'
        else
          if has_r99_sf20
            summary = 'You may not have access to campus services due to a hold. Please address your holds to become entitled to campus services.'
          else
            summary = 'Fees Unpaid'
          end
        end
      else
        summary = 'Not Enrolled in Classes'
      end
      summary
    end

    def set_regstatus_explanation_grad(term, summary)
      case summary
        when 'Fees Unpaid'
          return regstatus_messages[:feesUnpaidGrad]
        when 'Not Enrolled'
          return regstatus_messages[:notEnrolledGrad]
        else
          return nil
      end
    end

    def set_regstatus_summary_undergrad(term, registered)
      enrolled = enrolled?(term)
      if enrolled
        if registered[:isActive]
          summary = 'Officially Registered'
        else
          summary = 'Not Officially Registered'
        end
      else
        summary = 'Not Enrolled'
      end
      summary
    end

    def set_regstatus_explanation_undergrad(term, summary, registered)
      summer = term.try(:[], :isSummer)
      case summary
        when 'Officially Registered'
          if summer
            return 'You are officially registered for this term.'
          else
            return registered[:message]
          end
        when 'Not Officially Registered'
          if summer
            return 'You are not officially registered for this term.'
          else
            return regstatus_messages[:notOfficiallyRegistered]
          end
        when 'Not Enrolled'
          return regstatus_messages[:notEnrolledUndergrad]
      end
    end

    def set_cnp_flags(term_registrations)
      term_registrations.each do |term_id, term_value|
        term_value[:showCnp] = show_cnp? term_value
      end
    end

    def set_cnp_messaging(term_registrations)
      term_registrations.each do |term_id, term_value|
        show_cnp = term_value.try(:[], :showCnp)

        if show_cnp
          r99 = {isActive: term_includes_indicator?(term_value, '+R99')}
          rop = {isActive: term_includes_indicator?(term_value, '+ROP')}
          r99.merge!({message: extract_indicator_message(term_value, '+R99')}) if r99[:isActive]
          rop.merge!({message: extract_indicator_message(term_value, '+ROP')}) if rop[:isActive]
          past_financial_disbursement = get_term_flag(term_value, :pastFinancialDisbursement)
          term_value[:cnpStatus] = {
            summary: set_cnp_summary(r99, rop),
            explanation: set_cnp_explanation(r99, rop, past_financial_disbursement),
            popoverSummary: set_cnp_popover_summary(r99, rop, past_financial_disbursement)
          }
        end
      end
    end

    def set_cnp_summary(r99, rop)
      if r99[:isActive]
        return 'You Will Not Be Canceled for Non-Payment'
      elsif !r99[:isActive] && rop[:isActive]
        return 'You Are Subject to Cancel for Non-Payment - Deadline Extended'
      elsif !r99[:isActive] && !rop[:isActive]
        return 'You Are Subject to Cancel for Non-Payment'
      end
    end

    def set_cnp_popover_summary(r99, rop, past_financial_disbursement)
      if r99[:isActive]
        return 'You Will Not Be Canceled for Non-Payment'
      elsif !r99[:isActive] && rop[:isActive]
        return 'Temporary Protection from Cancel for Non-Payment'
      elsif !r99[:isActive] && !rop[:isActive]
        if past_financial_disbursement
          return '<strong>Warning: </strong>You Are Subject to Cancel for Non-Payment.'
        else
          return 'You Are Subject to Cancel for Non-Payment'
        end
      end
    end

    def set_cnp_explanation(r99, rop, past_financial_disbursement)
      if r99[:isActive]
        return r99[:message]
      elsif !r99[:isActive] && rop[:isActive]
        return rop[:message]
      elsif !r99[:isActive] && !rop[:isActive]
        if !past_financial_disbursement
          return regstatus_messages[:cnpNotificationUndergrad]
        else past_financial_disbursement
          return regstatus_messages[:cnpWarningUndergrad]
        end
      end
    end

    def show_regstatus?(term)
      past_end_of_instruction = get_term_flag(term, :pastEndOfInstruction)
      term_career = get_term_career(term)
      term_includes_indicator?(term, '+S09') && !past_end_of_instruction && (term_career != 'UCBX')
    end

    # Only consider showing CNP status for undergraduate non-summer terms in which the student is not already Officially Registered
    # If a student is Not Enrolled and does not have CNP protection through R99 or ROP, do not show CNP warning as there are no classes to be dropped from.
    # If a student is not Officially Registered but is protected from CNP via R99, show protected status regardless of where we are in the term.
    # Otherwise, show CNP status until CNP action is taken (start of classes)
    # If none of these conditions are met, do not show CNP status
    def show_cnp?(term)
      show_regstatus = term.try(:[], :showRegStatus)
      summer = term.try(:[], :isSummer)
      regstatus = term.try(:[], :regStatus).try(:[], :summary)
      undergrad = term.try(:[], 'academicCareer').try(:[], 'code') == 'UGRD'
      past_classes_start = get_term_flag(term, :pastClassesStart)

      if show_regstatus && undergrad && !summer && regstatus != 'Officially Registered'
        return false if regstatus == 'Not Enrolled' && (!term_includes_indicator?(term, '+R99') && !term_includes_indicator?(term, '+ROP'))
        if (regstatus != 'Officially Registered' && term_includes_indicator?(term, '+R99')) || !past_classes_start
          return true
        else
          return false
        end
      else
        return false
      end
    end

    def get_term_flag(term, flag)
      term.try(:[], :termFlags).try(:[], flag)
    end

    def get_term_career(term)
      term.try(:[], 'academicCareer').try(:[], 'code')
    end

    def enrolled?(term)
      term_units = term.try(:[], 'termUnits').find do |units|
        units.try(:[], 'type').try(:[], 'description') == 'Total'
      end
      enrolled_units = term_units.try(:[], 'unitsEnrolled')
      taken_units = term_units.try(:[], 'unitsTaken')
      (!enrolled_units.nil? && enrolled_units != 0) || (!taken_units.nil? && taken_units != 0)
    end

    def term_includes_indicator?(term, indicator_type)
      !!term.try(:[], :positiveIndicators).find do |indicator|
        indicator.try(:[], 'type').try(:[], 'code') == indicator_type
      end
    end

    # Graduate students receive R99 service indicators, but it's only related to their registration status if it has a reason code of 'SF20%'
    def term_includes_r99_sf20?(term)
      !!term.try(:[], :positiveIndicators).find do |indicator|
        indicator.try(:[], 'type').try(:[], 'code') == '+R99' && indicator.try(:[], 'reason').try(:[], 'code') == 'SF20%'
      end
    end

    def extract_indicator_message(term, indicator_type)
      term.try(:[], :positiveIndicators).find do |indicator|
        indicator.try(:[], 'type').try(:[], 'code') == indicator_type
      end.try(:[], 'reason').try(:[], 'formalDescription')
    end

  end
end

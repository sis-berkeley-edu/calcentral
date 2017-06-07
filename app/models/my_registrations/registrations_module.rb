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
        past_end_of_instruction = get_term_flag(term_value, :pastEndOfInstruction)
        term_value[:showRegStatus] = term_includes_indicator?(term_value, '+S09') && !past_end_of_instruction
      end
    end

    def set_summer_flags(term_registrations)
      term_registrations.each do |term_id, term_value|
        term_value[:isSummer] = term_value.try(:[], 'term').try(:[], 'name').include?('Summer')
      end
    end

    def set_regstatus_messaging(term_registrations)
      term_registrations.each do |term_id, term_value|
        regstatus_summary = set_regstatus_summary(term_value)
        term_value[:regStatus] = {
          summary: regstatus_summary,
          explanation: set_regstatus_explanation(term_value, regstatus_summary)
        }
      end
    end

    def set_regstatus_summary(term)
      registered = term_includes_indicator?(term, '+REG')
      enrolled = enrolled?(term)
      if registered && enrolled
        summary = 'Officially Registered'
      elsif !registered && enrolled
        summary = 'Not Officially Registered'
      else
        summary = 'Not Enrolled'
      end
      return summary
    end

    def set_regstatus_explanation(term, summary)
      summer = term.try(:[], :isSummer)
      undergrad = term.try(:[], 'academicCareer').try(:[], 'code') == 'UGRD'
      case summary
        when 'Officially Registered'
          if summer
            return 'You are officially registered for this term.'
          else
            return 'You are officially registered and are entitled to access campus services.'
          end
        when 'Not Officially Registered'
          if summer
            return 'You are not officially registered for this term.'
          else
            return regstatus_messages[:notOfficiallyRegistered]
          end
        when 'Not Enrolled'
          if undergrad
            return regstatus_messages[:notEnrolledUndergrad]
          else
            return regstatus_messages[:notEnrolledGrad]
          end
      end
    end

    def set_cnp_flags(term_registrations)
      term_registrations.each do |term_id, term_value|
        term_value[:showCnp] = show_cnp? term_value
      end
    end

    def set_cnp_messaging(term_registrations)
      term_registrations.each do |term_id, term_value|
        undergrad = term_value.try(:[], 'academicCareer').try(:[], 'code') == 'UGRD'
        has_r99 = term_includes_indicator?(term_value, '+R99')
        has_rop = term_includes_indicator?(term_value, '+ROP')
        past_financial_disbursement = term_value.try(:[], :termFlags).try(:[], :pastFinancialDisbursement)

        term_value[:cnpStatus] = {
          summary: set_cnp_summary(has_r99, has_rop, past_financial_disbursement),
          explanation: set_cnp_explanation(has_r99, has_rop, past_financial_disbursement, undergrad),
          popoverSummary: set_cnp_popover_summary(has_r99, has_rop, past_financial_disbursement)
        }
      end
    end

    def set_cnp_summary(has_r99, has_rop, past_financial_disbursement)
      if has_r99
        return 'You Will Not Be Canceled for Non-Payment'
      elsif !has_r99 && has_rop
        return 'Temporary Protection from Cancel for Non-Payment'
      elsif !has_r99 && !has_rop && !past_financial_disbursement
        return 'Cancel for Non-Payment Notification'
      elsif !has_r99 && !has_rop && past_financial_disbursement
        return 'Cancel for Non-Payment Warning'
      end
    end

    def set_cnp_popover_summary(has_r99, has_rop, past_financial_disbursement)
      if has_r99
        return '<strong>Exception: </strong>Your enrollment is not subject to cancellation this semester.'
      elsif !has_r99 && has_rop
        return 'Temporary Protection from Cancel for Non-Payment'
      elsif !has_r99 && !has_rop && !past_financial_disbursement
        return 'Cancel for Non-Payment Notification'
      elsif !has_r99 && !has_rop && past_financial_disbursement
        return '<strong>Warning: </strong>Your enrollment is not subject to cancellation this semester.'
      end
    end

    def set_cnp_explanation(has_r99, has_rop, past_financial_disbursement, undergrad)
      if has_r99
        'You have an exception from Cancellation for Non-Payment (CNP) for this term.  You will not be dropped from your classes for this term.
         You remain financially responsible for all charges on your Student Account.  Please monitor your communications and tasks in CalCentral for updates.'
      elsif !has_r99 && has_rop
        'The deadline to pay for this term has been extended.  To maintain enrollment in your current class schedule and avoid an administrative withdrawal, please pay
         at least 20% of your tuition and fees by August 30th.  Note that if you are dropped for non-payment you will be subject to the pro-rated fee schedule.
         <br><br>
         To learn more about the consequences of withdrawal please visit <a href="http://registrar.berkeley.edu/registration/cancellation-withdrawal/refunds-after-withdrawl">refunds after
         withdrawal.</a>'
      elsif !has_r99 && !has_rop
        if !past_financial_disbursement && undergrad
          return regstatus_messages[:cnpNotificationUndergrad]
        elsif !past_financial_disbursement && !undergrad
          return regstatus_messages[:cnpNotificationGrad]
        elsif past_financial_disbursement && undergrad
          return regstatus_messages[:cnpWarningUndergrad]
        elsif past_financial_disbursement && !undergrad
          return regstatus_messages[:cnpWarningGrad]
        else
          return 'You may be subject to <a href="http://registrar.berkeley.edu/cnp">Cancel for Non-Payment.</a>'
        end
      end
    end

    def show_cnp?(term)
      summer = term.try(:[], :isSummer)
      regstatus = term.try(:[], :regStatus).try(:[], :summary)
      undergrad = term.try(:[], 'academicCareer').try(:[], 'code') == 'UGRD'
      past_classes_start = get_term_flag(term, :pastClassesStart)
      past_add_drop = get_term_flag(term, :pastAddDrop)

      # Only consider showing CNP status for non-summer terms in which a student is not already Officially Registered
      if !summer && regstatus != 'Officially Registered'
        # If a student is Not Enrolled and does not have CNP protection through R99 or ROP, do not show CNP warning as there are no classes to be dropped from.
        # We need to run this block first, as it is possible for these conditions to be met and still return 'true' in the next block.
        return false if regstatus == 'Not Enrolled' && (!term_includes_indicator?(term, '+R99') && !term_includes_indicator?(term, '+ROP'))

        # If a student is not Officially Registered but is protected from CNP via R99, show protected status regardless of where we are in the term timeline.
        # Otherwise, show CNP status until CNP action is taken (start of classes for undergrads, 5 weeks into the term for grad/law)
        if (regstatus != 'Officially Registered' && term_includes_indicator?(term, '+R99')) || (undergrad && !past_classes_start) || (!undergrad && !past_add_drop)
          return true
        else
          return false
        end
      # If none of these conditions are met, do not show CNP status
      else
        return false
      end
    end

    def get_term_flag(term, flag)
      term.try(:[], :termFlags).try(:[], flag)
    end

    def term_includes_indicator?(term, indicator_type)
      !!term.try(:[], :positiveIndicators).find do |indicator|
        indicator.try(:[], 'type').try(:[], 'code') == indicator_type
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

  end
end

module MyRegistrations
  module CancellationNonPaymentModule
    extend self

    include SharedHelpers

    CNP_SUMMARIES = {
      notCanceled:            'You Will Not Be Canceled for Non-Payment',
      subjectCancel:          'You Are Subject to Cancel for Non-Payment',
      subjectCancelDeadline:  'You Are Subject to Cancel for Non-Payment - Deadline Extended',
      subjectCancelWarning:   '<strong>Warning: </strong>You Are Subject to Cancel for Non-Payment.',
      temporarilyProtected:   'Temporary Protection from Cancel for Non-Payment'
    }

    def set_cnp_flags(term_registrations)
      term_registrations.each do |term_id, term_value|
        term_value[:showCnp] = show_cnp? term_value
      end
    end

    # Only consider showing CNP status for undergraduate non-summer terms in which the student is not already Officially Registered
    # If a student is Not Enrolled and does not have CNP protection through R99 or ROP, do not show CNP warning as there are no classes to be dropped from.
    # If a student is not Officially Registered but is protected from CNP via R99, show protected status regardless of where we are in the term.
    # Otherwise, show CNP status until CNP action is taken (start of classes)
    # If none of these conditions are met, do not show CNP status
    def show_cnp?(term)
      is_undergrad = get_term_career(term) == CAREERS[:undergrad]
      return false unless is_undergrad

      summer = term[:isSummer]
      reg_summary = term[:regStatus][:summary]
      past_classes_start = get_term_flag(term, :pastClassesStart)

      if !summer && reg_summary != UGRD_SUMMARIES[:registered]
        return false if reg_summary == UGRD_SUMMARIES[:notEnrolled] && (!term_includes_indicator?(term, '+R99') && !term_includes_indicator?(term, '+ROP'))
        if (reg_summary != UGRD_SUMMARIES[:registered] && term_includes_indicator?(term, '+R99')) || !past_classes_start
          return true
        else
          return false
        end
      else
        return false
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
        return CNP_SUMMARIES[:notCanceled]
      elsif !r99[:isActive] && rop[:isActive]
        return CNP_SUMMARIES[:subjectCancelDeadline]
      elsif !r99[:isActive] && !rop[:isActive]
        return CNP_SUMMARIES[:subjectCancel]
      end
    end

    def set_cnp_popover_summary(r99, rop, past_financial_disbursement)
      if r99[:isActive]
        return CNP_SUMMARIES[:notCanceled]
      elsif !r99[:isActive] && rop[:isActive]
        return CNP_SUMMARIES[:temporarilyProtected]
      elsif !r99[:isActive] && !rop[:isActive]
        if past_financial_disbursement
          return CNP_SUMMARIES[:subjectCancelWarning]
        else
          return CNP_SUMMARIES[:subjectCancel]
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
          return reg_explanations[:cnpNotificationUndergrad]
        else past_financial_disbursement
        return reg_explanations[:cnpWarningUndergrad]
        end
      end
    end

  end
end

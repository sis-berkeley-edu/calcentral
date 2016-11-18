module Notifications
  class RegStatusTranslator

    def translate_for_feed(reg_status)
      {
        code: reg_status,
        summary: status(reg_status),
        explanation: status_explanation(reg_status),
        needsAction: !(reg_status.nil? || is_registered(reg_status))
      }
    end

    def status(reg_status)
      return nil if reg_status.nil?
      case reg_status.upcase
        when 'C', 'L', 'N', 'R', 'S', 'V'
          'Registered'
        when 'D'
          'Dismissed'
        when 'U', 'X'
          'Administratively Cancelled'
        when 'W'
          'Withdrawn'
        else
          'Not Registered'
      end
    end

    def is_registered(reg_status)
      return false if reg_status.nil?
      %w(C L N R S V).include? reg_status.upcase
    end

    def status_explanation(reg_status)
      return nil if reg_status.nil?

      case reg_status.upcase
        when 'C', 'L', 'N', 'R', 'S', 'V'
          'You are officially registered for this term and are entitled to access campus services.'
        when ' ', 'A'
          'In order to be officially registered, you must pay at least 20% of your registration fees, have no outstanding blocks, and be enrolled in at least one class.'
        when 'D'
          'You have been academically dismissed for this term.'
        when 'U'
          'You have been administratively cancelled for this term.'
        when 'X'
          'Your registration has been canceled for this term.'
        when 'Z'
          'The Office of the Registrar has been notified of the death of this student ID.'
        when 'W'
          'You are withdrawn for this term and may owe fees depending on your date of withdrawal.'
        else
          'Unknown Status.'
      end
    end

  end
end

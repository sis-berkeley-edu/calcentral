module Berkeley
  class DegreeProgressUndergrad
    include ClassLogger

    STATUS_SATISFIED = 'Satisfied'
    STATUS_NOT_SATISFIED = 'Not Satisfied'
    STATUS_IN_PROGRESS = 'In Progress'
    STATUS_UNDER_REVIEW = 'Under Review'

    def self.get_status(status_code, in_progress_value, is_pending_transfer_credit_review_deadline)
      return nil if status_code.blank?
      if (is_pending_transfer_credit_review_deadline)
        return grace_period_status(status_code.strip.upcase, in_progress_value)
      end
      self.status(status_code.strip.upcase, in_progress_value)
    end

    def self.grace_period_status(code, in_progress_value)
      complete?(code) && !in_progress?(in_progress_value) ? STATUS_SATISFIED : STATUS_UNDER_REVIEW
    end

    def self.status(code, in_progress_value)
      in_progress = complete?(code) && in_progress?(in_progress_value)
      return STATUS_IN_PROGRESS if in_progress
      complete?(code) ? STATUS_SATISFIED : STATUS_NOT_SATISFIED
    end

    def self.complete?(code)
      code == 'COMP'
    end

    def self.in_progress?(in_progress_value)
      in_progress_value == 'Y'
    end

    def self.requirements_whitelist
      requirements.keys
    end

    def self.get_description(requirement_code)
      requirements[Integer(requirement_code, 10)].try(:[], :description) unless requirement_code.blank?
    end

    def self.get_order(requirement_code)
      requirement = requirements[Integer(requirement_code, 10)] unless requirement_code.blank?
      if requirement
        requirement.fetch(:order)
      else
        logger.debug "Undefined requirement: #{requirement_code}"
        return
      end
    end

    def self.requirements
      @requirements ||= {
        1	=> {
          description: 'Entry Level Writing',
          order: 0
        },
        2	=> {
          description: 'American History',
          order: 1
        },
        18 => {
          description: 'American Institutions',
          order: 2
        },
        3	=> {
          description: 'American Cultures',
          order: 3
        }
      }
    end
  end
end

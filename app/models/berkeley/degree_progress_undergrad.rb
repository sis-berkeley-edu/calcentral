module Berkeley
  class DegreeProgressUndergrad
    include ClassLogger

    def self.get_status(status_code, in_progress_value)
      return nil if status_code.blank?
      uniform_status_code = status_code.strip.upcase
      in_progress = uniform_status_code == 'COMP' && in_progress_boolean(in_progress_value)
      in_progress ? 'In Progress' : statuses[uniform_status_code]
    end

    def self.in_progress_boolean(in_progress_value)
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

    def self.statuses
      @statuses ||= {
        'FAIL' => 'Not Satisfied',
        'COMP' => 'Satisfied'
      }
    end
  end
end

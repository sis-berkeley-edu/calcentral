module Berkeley
  class DegreeProgressUndergrad
    include ClassLogger

    def self.get_status(status_code)
      statuses[status_code.strip.upcase] unless status_code.blank?
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
        'FAIL' => 'Incomplete',
        'COMP' => 'Completed'
      }
    end
  end
end

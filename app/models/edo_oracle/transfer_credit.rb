module EdoOracle
  class TransferCredit < BaseProxy
    include ClassLogger
    include User::Identifiers

    def initialize(options = {})
      super(Settings.edodb, options)
    end

    def get_feed
      detailed = get_transfer_credit_detailed
      summary = get_transfer_credit_summary
      {
        undergraduate: {
          detailed: detailed[:undergraduate],
          summary: summary[:undergraduate]
        },
        graduate: {
          detailed: detailed[:graduate],
          summary: summary[:graduate]
        },
        law: {
          detailed: detailed[:law],
          summary: summary[:law]
        }
      }
    end

    def campus_solutions_id
      @cs_id ||= lookup_campus_solutions_id @uid
    end

    def get_total_transfer_units_law
      if (law_units = EdoOracle::Queries.get_total_transfer_units_law campus_solutions_id)
        return law_units.try(:[], 'total_transfer_units_law').try(:to_f)
      end
      nil
    end

    def get_transfer_credit_detailed
      if (transfer_credits = EdoOracle::Queries.get_transfer_credit_detailed campus_solutions_id)
        return parse_rows_detailed transfer_credits
      end
      nil
    end

    def get_transfer_credit_summary
      if (summaries = EdoOracle::Queries.get_transfer_credit_summary campus_solutions_id)
        return parse_rows_summary summaries
      end
      nil
    end

    def parse_rows_summary(summaries)
      valid_careers = %w(UGRD GRAD LAW)
      undergrad, grad, law = nil, nil, nil
      summaries.try(:each) do |summary|
        if (career = summary.try(:[], 'career')) && (valid_careers.include? career)
          parsed_summary = parse_row_summary summary
          case career
            when 'UGRD'
              parsed_summary[:careerDescr] = 'Undergraduate'
              undergrad = parsed_summary
            when 'GRAD'
              parsed_summary[:careerDescr] = 'Graduate'
              grad = parsed_summary
            when 'LAW'
              parsed_summary[:careerDescr] = 'Law'
              parsed_summary[:totalTransferUnitsLaw] = get_total_transfer_units_law
              law = parsed_summary
          end
        else
          next
        end
      end
      {
        undergraduate: undergrad,
        graduate: grad,
        law: law
      }
    end

    def parse_rows_detailed(transfer_credits)
      undergrad, grad, law = [], [], []
      transfer_credits.try(:each) do |credit|
        career = credit['career']
        case career
          when 'UGRD'
            parsed_credit = parse_non_law_credit credit
            undergrad.push parsed_credit
          when 'GRAD'
            parsed_credit = parse_non_law_credit credit
            grad.push parsed_credit
          when 'LAW'
            parsed_credit = parse_law_credit credit
            law.push parsed_credit
          else
            logger.warn("Transfer credit received for UID #{@uid} with unrecognizable career #{career}")
            next
        end
      end
      {
        undergraduate: undergrad.present? ? undergrad : nil,
        graduate: grad.present? ? grad : nil,
        law: law.present? ? law : nil
      }
    end

    def parse_law_credit(credit)
      {
        school: credit['school_descr'],
        units: credit['transfer_units'].try(:to_f),
        lawUnits: credit['law_transfer_units'].try(:to_f),
        requirementDesignation: credit['requirement_designation']
      }
    end

    def parse_non_law_credit(credit)
      {
        school: credit['school_descr'],
        units: credit['transfer_units'].try(:to_f),
        gradePoints: credit['grade_points'].try(:to_f)
      }
    end

    def parse_row_summary(summary)
      relevant_non_ugrd_fields = %w(career total_transfer_units transfer_units_adjusted)
      parsed = summary.try(:[], 'career') == 'UGRD' ? summary : summary.select { |k, v| relevant_non_ugrd_fields.include? k }
      parsed.try(:each) { |k, v| parsed[k] = v.is_a?(Numeric) ? v.try(:to_f) : v }
      HashConverter.camelize parsed
    end

  end
end

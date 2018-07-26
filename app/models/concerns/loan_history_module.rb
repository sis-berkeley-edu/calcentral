module Concerns
  module LoanHistoryModule
    extend self

    def calculate_estimated_monthly_payment(annual_interest_rate, principal_value, repayment_period)
      return nil unless annual_interest_rate && principal_value && repayment_period && (annual_interest_rate > 0)
      annual_interest = (annual_interest_rate / 100)
      monthly_interest = annual_interest / 12
      (monthly_interest * principal_value) / (1 - (1 + monthly_interest)**(-repayment_period))
    end

    def choose_monthly_payment(estimated, minimum, total_amount_owed)
      return nil unless estimated && minimum && total_amount_owed
      return total_amount_owed if total_amount_owed < minimum
      estimated < minimum ? minimum : estimated
    end

    def enrolled_pre_fall_2016? (campus_solutions_id)
      enrolled = EdoOracle::Queries.enrolled_pre_fall_2016 campus_solutions_id
      enrolled.try(:[], 'enrolled') == 'Y'
    end

    def is_loan_history_active? (campus_solutions_id)
      is_active = EdoOracle::Queries.get_loan_history_status campus_solutions_id
      is_active.try(:[], 'active') == 'Y'
    end

    def parse_edo_response_with_sequencing (response)
      return response unless response.is_a? Array
      response.map do |obj|
        sequence_int = obj.try(:[], 'sequence').try(:to_i)
        obj['sequence'] = sequence_int
        HashConverter.camelize(obj)
      end
    end

    def parse_owed_value(value)
      return 0 unless value.is_a? Numeric
      value > 0 ? value.try(:to_f).try(:round, 2) : 0
    end

  end
end

module Concerns
  module LoanHistoryModule
    extend self

    def calculate_estimated_monthly_payment(interest_rate, principal_value, repayment_period)
      return nil unless interest_rate && principal_value && repayment_period && (interest_rate > 0)
      # Interest rate is provided as a percentage, so we'll need to convert it to a value
      # Furthermore, we'll divide it by 12 since it is an annual interest rate, and repayment_period is in months
      interest = (interest_rate / 100) / 12
      (interest * principal_value) / (1 - (1+interest)**(-repayment_period))
    end

    def choose_monthly_payment(estimated, minimum)
      return nil unless estimated && minimum
      estimated < minimum ? minimum : estimated
    end

    def enrolled_pre_fall_2016? (campus_solutions_id)
      enrolled = EdoOracle::Queries.enrolled_pre_fall_2016 campus_solutions_id
      enrolled.try(:[], 'enrolled') == 'Y'
    end

    def is_loan_history_active? (campus_solutions_id)
      is_active = EdoOracle::Queries.is_loan_history_active campus_solutions_id
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

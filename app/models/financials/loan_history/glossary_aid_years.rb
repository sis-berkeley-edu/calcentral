module Financials
  module LoanHistory
    class GlossaryAidYears < Glossary

      def query
        EdoOracle::Queries.get_loan_history_glossary_aid_years
      end

    end
  end
end

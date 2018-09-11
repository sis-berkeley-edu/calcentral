module Financials
  module LoanHistory
    class GlossaryCumulative < Glossary

      def query
        EdoOracle::FinancialAid::Queries.get_loan_history_glossary_cumulative
      end

    end
  end
end

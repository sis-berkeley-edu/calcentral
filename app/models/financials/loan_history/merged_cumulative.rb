module Financials
  module LoanHistory
    class MergedCumulative < Merged

      def user_specific_providers
        [
          LoansCumulative
        ]
      end

      def globally_cached_providers
        [
          MessagingGeneral,
          Resources,
          GlossaryCumulative
        ]
      end

    end
  end
end

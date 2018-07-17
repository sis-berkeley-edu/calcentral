module Financials
  module LoanHistory
    class MergedInactive < Merged

      def globally_cached_providers
        [
          MessagingInactive,
          Resources
        ]
      end

    end
  end
end

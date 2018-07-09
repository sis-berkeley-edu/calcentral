module Financials
  module LoanHistory
    class MergedInactive < Merged

      def self.globally_cached_providers
        [
          MessagingInactive,
          Resources
        ]
      end

    end
  end
end

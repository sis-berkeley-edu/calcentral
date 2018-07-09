module Financials
  module LoanHistory
    class MergedAidYears < Merged
      include Concerns::LoanHistoryModule
      include User::Identifiers

      def user_specific_providers
        [
          LoansAidYears
        ]
      end

      def globally_cached_providers
        providers = [
          MessagingGeneral,
          Resources,
          GlossaryAidYears
        ]
        providers.push(MessagingPriorEnrollment) if enrolled_pre_fall_2016? lookup_campus_solutions_id
        providers
      end

    end
  end
end

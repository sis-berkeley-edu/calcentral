module Financials
  module LoanHistory
    class LoansSummary < UserSpecificModel
      include Cache::CachedFeed
      include Cache::UserCacheExpiry
      include Cache::RelatedCacheKeyTracker
      include Concerns::LoanHistoryModule
      include User::Identifiers

      def get_feed_internal
        loan_history_active = { active: is_loan_history_active?(lookup_campus_solutions_id), amountOwed: nil }
        loan_history_active[:active] ? loan_history_active.merge(get_cumulative_amount_owed) : loan_history_active
      end

      def get_cumulative_amount_owed
        cumulative_feed = LoansCumulative.new(@uid).get_feed
        loans_summary = cumulative_feed.delete(:loansSummary)
        { amountOwed: loans_summary[:amountOwed] }
      end

    end
  end
end

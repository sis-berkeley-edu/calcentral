module Financials
  module LoanHistory
    class LoansSummary < UserSpecificModel
      include Cache::CachedFeed
      include Cache::UserCacheExpiry
      include Cache::RelatedCacheKeyTracker
      include Concerns::LoanHistoryModule
      include User::Identifiers

      def get_feed_internal
        active = is_loan_history_active? lookup_campus_solutions_id
        { active: active, amountOwed: active ? get_cumulative_amount_owed : nil }
      end

      def get_cumulative_amount_owed
        cumulative_feed = LoansCumulative.new(@uid).get_feed
        loans_summary = cumulative_feed.delete(:loansSummary)
        loans_summary.try(:[], :amountOwed)
      end

    end
  end
end

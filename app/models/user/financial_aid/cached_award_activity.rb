module User
  module FinancialAid
    class CachedAwardActivity < UserSpecificModel
      include Cache::CachedFeed
      include Cache::UserCacheExpiry
      include Cache::RelatedCacheKeyTracker

      def initialize(uid, aid_year)
        @uid = uid
        @aid_year = aid_year
      end

      def instance_key
        "#{@uid}-#{@aid_year}"
      end

      def get_feed_internal
        Queries.get_award_activity_dates(@uid, aid_year: @aid_year)
      end
    end
  end
end

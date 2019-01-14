module CampusSolutions
  class MyFinancialAidData < UserSpecificModel

    include ClassLogger
    include Cache::CachedFeed
    include Cache::UserCacheExpiry
    include Cache::RelatedCacheKeyTracker
    include CampusSolutions::FinaidFeatureFlagged

    attr_accessor :aid_year

    def get_feed_internal
      if is_feature_enabled && (self.aid_year ||= FinancialAid::MyAidYears.new(@uid).default_aid_year)
        CampusSolutions::FinancialAidData.new(user_id: @uid, aid_year: aid_year).get\
      else
        {}
      end
    end

    def instance_key
      "#{@uid}-#{aid_year}"
    end

  end
end

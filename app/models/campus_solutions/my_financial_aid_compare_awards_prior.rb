module CampusSolutions
  class MyFinancialAidCompareAwardsPrior < UserSpecificModel

    include ClassLogger
    include Cache::CachedFeed
    include Cache::UserCacheExpiry
    include Cache::JsonAddedCacher
    include Cache::RelatedCacheKeyTracker
    include CampusSolutions::FinancialAidCompareAwardsFeatureFlagged

    attr_accessor :aid_year
    attr_accessor :date

    def get_feed_internal
      if is_feature_enabled && (self.aid_year ||= CampusSolutions::MyAidYears.new(@uid).default_aid_year)
        logger.debug "User #{@uid}; aid year #{aid_year}; date #{date}"
        CampusSolutions::FinancialAidCompareAwardsPrior.new(user_id: @uid, aid_year: aid_year, date: date).get
      else
        {}
      end
    end

    def instance_key
      "#{@uid}-#{aid_year}-#{date}"
    end

  end
end

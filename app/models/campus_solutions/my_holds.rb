module CampusSolutions
  class MyHolds < UserSpecificModel

    include Cache::CachedFeed
    include Cache::JsonifiedFeed
    include Cache::UserCacheExpiry
     include CampusSolutions::HoldsFeatureFlagged

    def get_feed_internal
      return {} unless is_feature_enabled
      CampusSolutions::Holds.new({user_id: @uid}).get
    end

  end
end

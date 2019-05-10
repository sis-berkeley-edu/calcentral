module CampusSolutions
  module Billing
    class MyActivity < UserSpecificModel

      include Cache::CachedFeed
      include Cache::JsonifiedFeed
      include Cache::UserCacheExpiry
      include BillingFeatureFlagged

      def get_feed_internal
        return {} unless is_feature_enabled
        CampusSolutions::Billing::Activity.new({user_id: @uid}).get
      end

    end
  end
end

module User
  module Academics
    class CalgrantAcknowledgementsCached < UserSpecificModel
      include Cache::CachedFeed
      include Cache::UserCacheExpiry

      def get_feed_internal
        ::CalGrant::Queries.get_activity_guides(@uid)
      end
    end
  end
end

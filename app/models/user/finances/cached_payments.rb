module User
  module Finances
    class CachedPayments < UserSpecificModel
      include Cache::CachedFeed
      include Cache::UserCacheExpiry
      include Cache::RelatedCacheKeyTracker

      def initialize(uid, id)
        @uid = uid
        @id = id
      end

      def instance_key
        "#{@uid}-#{@id}"
      end

      def get_feed_internal
        Queries.uid_payments_by_item_number(@uid, @id)
      end
    end
  end
end


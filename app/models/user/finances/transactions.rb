module User
  module Finances
    class Transactions
      include Cache::CachedFeed
      include Cache::UserCacheExpiry

      def initialize(uid)
        @uid = uid
      end

      def instance_key
        @uid
      end

      def get_feed_internal
        Queries.transactions_for(@uid)
      end
    end
  end
end

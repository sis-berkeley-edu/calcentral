module User
  module Notifications
    class CachedFeed < UserSpecificModel
      include Cache::CachedFeed
      include Cache::JsonifiedFeed
      include Cache::UserCacheExpiry

      def get_feed_internal
        user.notifications
      end

      def user
        @user ||= User::Current.new(@uid)
      end
    end
  end
end

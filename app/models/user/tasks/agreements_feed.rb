module User
  module Tasks
    class AgreementsFeed < UserSpecificModel
      include Cache::CachedFeed
      include Cache::JsonifiedFeed
      include Cache::UserCacheExpiry

      def get_feed_internal
        {
          completedAgreements: user.completed_agreements.visible,
          incompleteAgreements: user.incomplete_agreements,
        }
      end

      def user
        @user ||= User::Current.new(@uid)
      end
    end
  end
end

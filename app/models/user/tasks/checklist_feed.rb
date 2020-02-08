module User
  module Tasks
    class ChecklistFeed < UserSpecificModel
      include Cache::CachedFeed
      include Cache::JsonifiedFeed
      include Cache::UserCacheExpiry

      def get_feed_internal
        {
          completedItems: user.completed_checklist_items,
          incompleteItems: user.incomplete_checklist_items,
        }
      end

      def user
        @user ||= User::Current.new(@uid)
      end
    end
  end
end

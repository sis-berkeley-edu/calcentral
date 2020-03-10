module User
  module Notifications
    module Concern
      extend ActiveSupport::Concern

      included do
        def notifications_feed
          @cached_feed ||= ::User::Notifications::CachedFeed.new(uid)
        end

        def notifications
          @notifications ||= ::User::Notifications::Notifications.new(self)
        end

        def display
          @display ||= ::User::Notifications::Display.new(uid)
        end
      end
    end
  end
end

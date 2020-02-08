module User
  module Tasks
    class WebMessagesController < ApplicationController
      include AllowDelegateViewAs
      include CurrentUserConcern

      def index
        render json: user.notifications_feed.get_feed
      end
    end
  end
end

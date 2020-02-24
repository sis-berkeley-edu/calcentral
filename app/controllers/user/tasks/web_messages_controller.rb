module User
  module Tasks
    class WebMessagesController < ApplicationController
      include AllowDelegateViewAs
      include CurrentUserConcern

      def index
        render json: user.web_messages.get_feed
      end
    end
  end
end

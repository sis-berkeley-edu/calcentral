module User
  module Tasks
    class CanvasMessagesController < ApplicationController
      include AllowDelegateViewAs
      include CurrentUserConcern

      def index
        render json: user.b_courses.activities_feed
      end
    end
  end
end

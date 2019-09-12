module User
  module Academics
    class StatusAndHoldsController < ApplicationController
      include AllowDelegateViewAs

      def index
        render json: user.status_and_holds
      end

      def user
        User::Current.new(session['user_id'])
      end
    end
  end
end

module User
  module Academics
    class DiplomaController < ApplicationController
      include AllowDelegateViewAs

      # GET /api/my/academics/diploma(.:format)
      def index
        render json: user.diploma
      end

      def user
        User::Current.new(session['user_id'])
      end
    end
  end
end

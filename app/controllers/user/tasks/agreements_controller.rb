module User
  module Tasks
    class AgreementsController < ApplicationController
      include CurrentUserConcern

      def index
        render json: user.agreements.get_feed
      end
    end
  end
end

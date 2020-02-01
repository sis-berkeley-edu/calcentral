module User
  module Tasks
    class ChecklistItemsController < ApplicationController
      include AllowDelegateViewAs
      include CurrentUserConcern

      def index
        render json: user.checklist_items.get_feed
      end
    end
  end
end

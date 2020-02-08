module User
  module Tasks
    class BCoursesTodosController < ApplicationController
      include AllowDelegateViewAs
      include CurrentUserConcern

      def index
        render json: {
          bCoursesTodos: user.b_courses.filtered_tasks
        }
      end
    end
  end
end

module User
  module BCourses
    module Concern
      extend ActiveSupport::Concern

      included do
        def b_courses
          @b_courses ||= ::User::BCourses::BCourses.new(self)
        end

        def has_canvas_access?
          @has_canvas_access ||= Canvas::Proxy.access_granted?(uid)
        end
      end
    end
  end
end

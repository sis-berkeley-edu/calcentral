module User
  module BCourses
    module Concern
      extend ActiveSupport::Concern

      included do
        def b_courses
          @b_courses ||= ::User::BCourses::BCourses.new(self)
        end
      end
    end
  end
end

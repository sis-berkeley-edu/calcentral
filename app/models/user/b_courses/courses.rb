module User
  module BCourses
    class Courses
      attr_accessor :user

      def initialize(user)
        self.user = user
      end

      def all
        @all ||= courses_data.collect do |course_data|
          Course.new(course_data)
        end
      end

      def id_course_id_map
        @id_course_code_map ||= all.collect(&:id).zip(all.collect(&:course_code)).to_h
      end

      def find_by_id(id)
        all.find { |course| course.id == id }
      end

      private

      def courses_data
        @courses_data ||= ::Canvas::UserCourses.new(user_id: user.uid).courses
      end
    end
  end
end

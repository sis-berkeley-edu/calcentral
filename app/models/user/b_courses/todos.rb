module User
  module BCourses
    class Todos
      attr_accessor :user

      def initialize(user)
        self.user = user
      end

      # Return all items where there is an assignment present
      def all
        @all ||= data.collect do |item|
          todo = Todo.new(item.merge(user: user))
        end
      end

      def with_assignment_non_grading
        all.select(&:has_assignment?).reject(&:grading?)
      end

      private

      def data
        @data ||= ::Canvas::Todo.new(user_id: user.uid).todo.fetch(:body) { [] }
      end
    end
  end
end

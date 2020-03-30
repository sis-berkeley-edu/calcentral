module User
  module BCourses
    class Events
      attr_accessor :user

      def initialize(user)
        self.user = user
      end

      def all
        data.collect do |datum|
          Event.new(datum.merge(user: user))
        end
      end

      def with_assignment_non_grading
        all.select(&:has_assignment?).select(&:no_grading_count?)
      end

      def data
        @data ||= ::Canvas::UpcomingEvents.new(user_id: user.uid).upcoming_events.fetch(:body) { [] }
      end
    end
  end
end

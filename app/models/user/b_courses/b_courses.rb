module User
  module BCourses
    class BCourses
      attr_accessor :user

      def initialize(user)
        self.user = user
      end

      def activities
        @activities ||= Activities.new(user, dashboard_sites)
      end

      # Collects all Todos and Events and removes those
      def filtered_tasks
        assignment_urls = []

        @filtered_tasks ||= tasks.select do |item|
          found_url = assignment_urls.find { |url| url == item.assignment_url }

          if found_url
            false
          else
            assignment_urls.push(item.assignment_url)
          end
        end
      end

      def courses
        @courses ||= Courses.new(user)
      end

      def dashboard_sites
        @dashboard_sites ||= ::MyActivities::DashboardSites.fetch(user.uid, {})
      end

      private

      def tasks
        collected_items ||= Array.new.tap do |tasks_array|
          todos.with_assignment_non_grading.each do |todo|
            tasks_array.push(todo)
          end

          events.with_assignment_non_grading.each do |event|
            tasks_array.push(event)
          end
        end
      end

      def todos
        @todos ||= Todos.new(user)
      end

      def events
        @events ||= Events.new(user)
      end
    end
  end
end

module User
  module BCourses
    class Activities
      attr_accessor :user, :dashboard_sites

      def initialize(user, dashboard_sites)
        self.user = user
        self.dashboard_sites = dashboard_sites
      end

      def as_json(options={})
        all
      end

      def all
        @all ||= data.collect do |datum|
          Activity.new(datum.merge(dashboard_sites: dashboard_sites))
        end
      end

      def filtered
        all.select(&:has_processed_title?).select(&:has_max_date?)
      end

      private

      def data
        @data ||= ::Canvas::UserActivityStream.new(user_id: user.uid).user_activity.fetch(:body) { [] }
      end
    end
  end
end

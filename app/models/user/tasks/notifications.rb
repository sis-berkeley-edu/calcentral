module User
  module Tasks
    class Notifications < ::User::Owned
      def as_json(options={})
        {
          notifications: all,
          archiveUrl: archive_url
        }
      end

      def all
        @all ||= data.map do |message|
          Notification.new(message.merge(user: user))
        end
      end

      private

      def data
        @data ||= User::Tasks::Queries.notifications(uid) || []
      end

      def archive_url
        return @archive_url if defined? @archive_url
        feed = CampusSolutions::DashboardUrl.new.get
        @archive_url = feed && feed[:feed] && feed[:feed][:url]
      end
    end
  end
end

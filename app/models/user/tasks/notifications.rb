module User
  module Tasks
    class Notifications < ::User::Owned
      def as_json(options={})
        {
          notifications: all,
          canvas_activities: user.b_courses.activities.filtered,
          webcasts: user.webcasts.all,
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
        @archive_url ||= LinkFetcher.fetch_link('UC_CC_WEBMSG_ARCHIVE')
      end
    end
  end
end

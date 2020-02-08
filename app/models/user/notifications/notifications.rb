module User
  module Notifications
    class Notifications < ::User::Owned
      def as_json(options={})
        {
          universityNotifications: {
            archiveUrl: archive_url,
            displayAll: display_all?,
            notifications: all,
          },
          canvas_activities: user.b_courses.activities.filtered,
          webcasts: user.webcasts.all,
        }
      end

      def display_all?
        user.display.display_all?
      end

      def all
        @all ||= data.map do |message|
          Notification.new(message.merge(user: user))
        end
      end

      private

      def data
        @data ||= User::Notifications::Queries.notifications(uid) || []
      end

      def archive_url
        @archive_url ||= LinkFetcher.fetch_link('UC_CC_WEBMSG_ARCHIVE')
      end
    end
  end
end

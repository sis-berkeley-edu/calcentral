module User
  module Notifications
    class Display
      attr_accessor :uid

      def initialize(uid)
        self.uid = uid
      end

      # used for new admits to make sure all the things they need to do are listed
      # w/o counting on them to click the show more button
      #
      # if (display_all && before the cutoff date)
      # then actually show all message w/o show more button.

      def display_all_expired?
        data['display_all_expires'].to_date.in_time_zone < Date.today.beginning_of_day.in_time_zone
      end

      def display_all?
        if display_all_expired?
          false
        else
          data['should_display_all'] == 'Y'
        end
      end

      def data
        @data ||= ::User::Notifications::Queries.web_message_display(uid).first
      end
    end
  end
end

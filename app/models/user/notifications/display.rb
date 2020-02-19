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
      def display_all?
        return false if data.nil? || display_all_expired?
        should_display?
      end

      def display_all_expired?
        return true if data.nil?
        return false if expiration_date.nil?
        expiration_date < Date.today.beginning_of_day.in_time_zone
      end

      private

      def data
        @data ||= ::User::Notifications::Queries.web_message_display(uid).first
      end

      def expiration_date
        data['display_all_expires']&.to_date&.in_time_zone
      end

      def should_display?
        data['should_display_all'] == 'Y'
      end
    end
  end
end

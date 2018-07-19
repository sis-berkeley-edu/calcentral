module Financials
  module LoanHistory
    class MessagingPriorEnrollment < Messaging

      def self.MESSAGE_IDS
        { enrolledPriorToFall2016: '2168' }
      end

    end
  end
end

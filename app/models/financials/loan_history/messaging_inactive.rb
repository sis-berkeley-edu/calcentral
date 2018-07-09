module Financials
  module LoanHistory
    class MessagingInactive < Messaging

      def self.MESSAGE_IDS
        { inactiveLoanHistory: 'INAC' }
      end

    end
  end
end

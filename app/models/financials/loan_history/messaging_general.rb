module Financials
  module LoanHistory
    class MessagingGeneral < Messaging

      def self.MESSAGE_IDS
        { estimatedPaymentDisclaimer: 'DSCL' }
      end

    end
  end
end

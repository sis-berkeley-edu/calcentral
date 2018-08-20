module Financials
  module LoanHistory
    class Messaging
      include Cache::CachedFeed

      def self.MESSAGE_IDS
        {}
      end

      def merge(data)
        data.deep_merge!(get_feed)
      end

      def get_feed_internal
        { messaging: get_messages }
      end

      def get_messages
        message_codes = self.class.MESSAGE_IDS.values
        message_data = EdoOracle::FinancialAid::Queries.get_loan_history_messages message_codes

        self.class.MESSAGE_IDS.keys.map do |message_code|
          relevant_message = message_data.try(:find) { |message| message.try(:[], 'code') ==  self.class.MESSAGE_IDS[message_code] }
          [message_code, HashConverter.camelize(relevant_message)]
        end.to_h
      end

      def instance_key
        nil
      end
    end
  end
end

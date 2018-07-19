module Financials
  module LoanHistory
    class Resources
      include Cache::CachedFeed
      include Concerns::LoanHistoryModule

      def merge(data)
        data.merge!(get_feed)
      end

      def get_feed_internal
        { links: get_links }
      end

      def get_links
        links_data = Array.wrap(EdoOracle::Queries.get_loan_history_resources)
        parse_edo_response_with_sequencing links_data
      end

      def instance_key
        nil
      end


    end
  end
end

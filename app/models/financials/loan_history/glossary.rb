module Financials
  module LoanHistory
    class Glossary
      include Cache::CachedFeed
      include Concerns::LoanHistoryModule

      def merge(data)
        data.merge!(get_feed)
      end

      def get_feed_internal
        { glossary: get_glossary }
      end

      def get_glossary
        if (glossary_data = query)
          parse_edo_response_with_sequencing glossary_data
        end
      end

      def query
        nil
      end

      def instance_key
        nil
      end
    end
  end
end

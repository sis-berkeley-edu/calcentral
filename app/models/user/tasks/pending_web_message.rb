module User
  module Tasks
    class PendingWebMessage

      # TODO: give this a name to explain why this context string is filtered from the view
      FILTERED_CONTEXT = 'ZAGR'

      attr_reader :data

      def initialize(data)
        @data = data
      end

      def as_json(options={})
        {
          title: title,
          context: context,
          url: url,
          id: comm_transaction_id,
          raw: data
        }
      end

      def displayed?
        context != FILTERED_CONTEXT
      end

      def title
        data[:descr]
      end

      def context
        data[:commContext]
      end

      def description
        data[:commCenterDescr]
      end

      def url
        data[:url]
      end

      def comm_transaction_id
        @comm_transaction_id ||= Rack::Utils.parse_query(URI(url).query)['ucCommTransID']
      end
    end
  end
end

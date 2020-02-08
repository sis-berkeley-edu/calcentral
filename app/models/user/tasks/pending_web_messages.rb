module User
  module Tasks
    class PendingWebMessages < ::User::Owned
      def as_json(options={})
        filtered
      end

      def filtered
        all.select(&:displayed?)
      end

      def all
        @all ||= data.collect do |message|
          PendingWebMessage.new message
        end
      end

      def find_by_transaction_id(id)
        all.find { |message| message.comm_transaction_id == id }
      end

      private

      def data
        @data ||= ::CampusSolutions::PendingMessages.new(user_id: user.uid).get[:feed][:commMessagePendingResponse]
      rescue NoMethodError
        []
      end
    end
  end
end

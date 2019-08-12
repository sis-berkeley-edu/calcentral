module User
  module Finances
    class Payments
      def initialize(user, id)
        @user = user
        @id = id
      end

      def as_json(options={})
        all
      end

      def all
        query_results.map do |data|
          ::User::Finances::Payment.new(data)
        end
      end

      def query_results
        @query_results ||= CachedPayments.new(@user.uid, @id).get_feed
      end
    end
  end
end

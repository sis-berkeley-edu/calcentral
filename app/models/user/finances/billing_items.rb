module User
  module Finances
    class BillingItems
      attr_reader :user

      def initialize(user)
        @user = user
      end

      def as_json(options={})
        billing_items.values.sort_by { |item| item.id }
      end

      def query_results
        @query_results ||= Transactions.new(uid).get_feed
      end

      def find_by_id(id)
        billing_items.fetch(id) { raise "Billling Item not found" }
      end

      private

      def uid
        user.uid
      end

      def billing_items
        @billing_items || default_hash.tap do |items|
          query_results.map do |data|
            items[data['item_id']] << data
          end
        end
      end

      def default_hash
        Hash.new { |hash, key| hash[key] = BillingItem.new(key, user) }
      end
    end
  end
end

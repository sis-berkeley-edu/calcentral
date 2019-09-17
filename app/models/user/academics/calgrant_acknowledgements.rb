module User
  module Academics
    class CalgrantAcknowledgements
      attr_reader :user

      def initialize(user)
        @user = user
      end

      def as_json(options={})
        all
      end

      def all
        query_results.map do |data|
          ::User::Academics::CalgrantAcknowledgement.new(
            user: user,
            id: data['id'],
            term_id: data['term_id'],
            status: data['status']
          )
        end
      end

      def find_by_term_id(term_id)
        all.find { |attr| attr.term_id == term_id }
      end

      private

      def query_results
        @query_results ||= CalgrantAcknowledgementsCached.new(@user.uid).get_feed
      end
    end
  end
end

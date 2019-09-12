module User
  module Academics
    class Registrations
      attr_reader :user

      def initialize(user)
        @user = user
      end

      def all
        data_feed.map do |data|
          ::User::Academics::Registration.new(data)
        end
      end

      def term_ids
        all.map { |attr| attr.term_id }.compact.uniq
      end

      def find_by_term_id(term_id)
        all.select { |attr| attr.term_id == term_id }
      end

      def data_feed
        @registrations ||= HubEdos::StudentApi::V2::Registrations.new(user_id: user.uid).get[:feed]['registrations'] || []
      rescue NoMethodError
        []
      end
    end
  end
end

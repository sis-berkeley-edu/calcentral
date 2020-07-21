module User
  module Academics
    class Holds
      attr_reader :user

      def initialize(user)
        @user = user
      end

      def all
        @all ||= feed_data.map do |data|
          ::User::Academics::Hold.new(data)
        end
      end

      def find_by_term_id(term_id)
        all.select do |hold|
          hold.term_id == term_id
        end
      end

      private

      def feed_data
        @feed_data ||= HubEdos::StudentApi::V2::Feeds::AcademicStatuses.new({ user_id: user.uid }).get[:feed]['holds'] || []
      rescue NoMethodError
        []
      end
    end
  end
end

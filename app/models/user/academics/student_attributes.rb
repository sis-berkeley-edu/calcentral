module User
  module Academics
    class StudentAttributes
      attr_reader :user

      def initialize(user)
        @user = user
      end

      def as_json(options={})
        all
      end

      def all
        feed_data.map do |data|
          ::User::Academics::StudentAttribute.new(data)
        end
      end

      def find_by_term_id(term_id)
        all.select { |attr| attr.term_id == term_id }
      end

      def term_ids
        all.map { |attr| attr.term_id }.compact.uniq
      end

      def feed_data
        @feed_data ||= HubEdos::StudentApi::V2::StudentAttributes.new(user_id: user.uid).get[:feed]['studentAttributes']
      rescue NoMethodError
        []
      end
    end
  end
end

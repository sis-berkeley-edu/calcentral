module User
  module Academics
    class StudentGroups
      def initialize(user)
        @user = user
      end

      def as_json(options={})
        all
      end

      def codes
        all.collect {|group| group.code }
      end

      def all
        query_results.map do |data|
          ::User::Academics::StudentGroup.new(data)
        end
      end

      def query_results
        @query_results ||= StudentGroupsCached.new(@user).get_feed
      end
    end
  end
end

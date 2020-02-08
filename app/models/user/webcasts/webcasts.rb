module User
  module Webcasts
    class Webcasts
      attr_accessor :user

      def initialize(user)
        self.user = user
      end

      def all
        @all ||= data.collect do |datum|
          ::User::Webcasts::Webcast.new(datum)
        end
      end

      private

      def data
        @data ||= Array.new.tap do |array|
          ::MyActivities::Webcasts.append!(user.uid, array)
        end
      end
    end
  end
end

module User
  module Academics
    class Levels
      attr_reader :data

      def initialize(data)
        @data = data
      end

      def all
        data.collect {|level| ::User::Academics::Level.new(level) }
      end
    end
  end
end

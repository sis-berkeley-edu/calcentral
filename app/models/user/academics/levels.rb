module User
  module Academics
    class Levels
      attr_reader :data

      def initialize(data)
        @data = data
      end

      def all
        data.collect {|level| ::User::Academics::Level.new(level)}
      end

      def preferred_for_career_code(career_code)
        all.find { |level| level.preferred_for_career_code?(career_code) }
      end
    end
  end
end

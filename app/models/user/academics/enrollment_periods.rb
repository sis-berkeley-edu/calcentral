module User
  module Academics
    class EnrollmentPeriods
      attr_reader :data

      def initialize(data = [])
        @data = data
      end

      def all
        @all ||= data.collect do |period_data|
          ::User::Academics::EnrollmentPeriod.new(period_data)
        end
      end

      def for_career(career_code)
        all.select do |period|
          period.career&.downcase == career_code&.downcase
        end
      end

      def as_json
        all.collect(&:as_json)
      end
    end
  end
end

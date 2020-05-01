module User
  module Academics
    class EnrollmentTermInstruction
      attr_reader :user
      attr_reader :term_id

      def initialize(user, term_id)
        @user = user
        @term_id = term_id
      end

      def enrollment_periods
        @enrollment_periods ||= EnrollmentPeriods.new(enrollment_period_data)
      end

      def enrollment_careers
        @enrollment_careers ||= EnrollmentCareers.new(enrollment_careers_data)
      end

      def as_json(options={})
        {
          user: user.uid,
          term_id: term_id,
          enrollment_periods: enrollment_periods.as_json,
          enrollment_careers: enrollment_careers.as_json
        }
      end

      private

      def enrollment_period_data
        data[:enrollmentTerm][:enrollmentPeriod] || []
      rescue NoMethodError
        []
      end

      def enrollment_careers_data
        data[:enrollmentTerm][:careers] || []
      rescue NoMethodError
        []
      end

      def data
        @data ||= ::CampusSolutions::EnrollmentTerm.new({
          user_id: user.uid,
          term_id: term_id
        }).get[:feed]
      end
    end
  end
end

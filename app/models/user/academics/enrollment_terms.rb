module User
  module Academics
    class EnrollmentTerms
      attr_accessor :user

      def initialize(user)
        self.user = user
      end

      def all
        @all ||= enrollments_data.collect do |data|
          EnrollmentTerm.new(data.merge({
            student_attributes: user.student_attributes,
            enrollment_instructions: user.enrollment_term_instructions,
            term_plans: user.term_plans,
          }))
        end
      end

      def as_json(options={})
        all.map(&:as_json)
      end

      private

      def enrollments_data
        @enrollments_data = CampusSolutions::EnrollmentTerms
          .new({ user_id: user.uid }).get[:feed][:enrollmentTerms]
      rescue NoMethodError
        []
      end
    end
  end
end

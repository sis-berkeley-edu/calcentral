module User
  module Academics
    class EnrollmentTerm
      attr_accessor :student_attributes
      attr_accessor :enrollment_instructions

      attr_accessor :term_id
      attr_accessor :term_descr
      attr_accessor :acad_career

      def initialize(attrs={})
        attrs.each do |key, value|
          method = "#{key.to_s.underscore}="
          self.send(method, value) if respond_to?(method)
        end
      end

      def as_json(options={})
        {
          career: career,
          termId: term_id,
          requiresCalgrantAcknowledgement: requires_cal_grant_acknowledgement?,
          message: message,
          enrollmentPeriods: enrollment_periods,
          constraints: enrollment_career,
        }
      end

      def requires_cal_grant_acknowledgement?
        student_attributes
          .find_by_term_id(term_id)
          .any?(&:requires_cal_grant_acknowledgement?)
      end

      def message
        return unless has_message_key?
        @message ||= CampusSolutions::MessageCatalog.get_message(message_key)
      end

      private

      def has_message_key?
        @message_key ||= CampusSolutions::MessageCatalog::CATALOG.fetch(message_key) { false }
      end

      def message_key
        "covid_pnp_notice_#{career}_#{term_id}".to_sym
      end

      def career
        acad_career.downcase
      end

      def enrollment_instruction
        @enrollment_instruction ||= enrollment_instructions.find_by_term_id(term_id)
      end

      def enrollment_periods
        @enrollment_periods ||= enrollment_instruction.enrollment_periods.for_career(career)
      end

      def enrollment_career
        @enrollment_career ||= enrollment_instruction.enrollment_careers.find_by_career_code(career)
      end
    end
  end
end

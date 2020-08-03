module User
  module Academics
    class EnrollmentTerm
      attr_accessor :student_attributes
      attr_accessor :enrollment_instructions
      attr_accessor :term_plans

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
          career: career_code,
          termId: term_id,
          requiresCalgrantAcknowledgement: requires_cal_grant_acknowledgement?,
          message: enrollment_message,
          classInfoMessage: class_info_message,
          enrollmentPeriods: enrollment_periods,
          constraints: enrollment_career,
          programCode: term_plan&.academic_program_code
        }
      end

      def requires_cal_grant_acknowledgement?
        student_attributes
          .find_by_term_id(term_id)
          .any?(&:requires_cal_grant_acknowledgement?)
      end

      def class_info_message
        ClassInfoMessage.new({
          career_code: career_code,
          semester_name: semester_name
        }).message
      end

      def enrollment_message
        EnrollmentMessage.new({
          career_code: career_code,
          semester_name: semester_name
        }).message
      end

      private

      delegate :semester_name, to: :term

      def term
        @term ||= ::User::Academics::Term.new(term_id)
      end

      def term_plan
        term_plans.find_by_term_id_and_career_code(term_id, career_code)
      end

      def career_code
        acad_career.downcase
      end

      def enrollment_instruction
        @enrollment_instruction ||= enrollment_instructions.find_by_term_id(term_id)
      end

      def enrollment_periods
        @enrollment_periods ||= enrollment_instruction.enrollment_periods.for_career(career_code)
      end

      def enrollment_career
        @enrollment_career ||= enrollment_instruction.enrollment_careers.find_by_career_code(career_code)
      end
    end
  end
end

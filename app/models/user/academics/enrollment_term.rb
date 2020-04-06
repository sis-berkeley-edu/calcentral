module User
  module Academics
    class EnrollmentTerm
      attr_accessor :student_attributes
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
          termId: term_id,
          requiresCalgrantAcknowledgement: requires_cal_grant_acknowledgement?
        }
      end

      def requires_cal_grant_acknowledgement?
        student_attributes
          .find_by_term_id(term_id)
          .any?(&:requires_cal_grant_acknowledgement?)
      end
    end
  end
end

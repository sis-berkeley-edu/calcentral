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
          requiresCalgrantAcknowledgement: requires_cal_grant_acknowledgement?,
          message: message,
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
    end
  end
end

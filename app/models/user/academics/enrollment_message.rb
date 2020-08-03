module User
  module Academics
    class EnrollmentMessage
      attr_reader :career_code, :semester_name

      def initialize(career_code:, semester_name:)
        @career_code = career_code
        @semester_name = semester_name.downcase
      end

      def message
        return unless has_key?
        @message ||= CampusSolutions::MessageCatalog.get_message(key)
      end

      private

      def key
        "enrollment_message_#{career_code}_#{semester_name}"
      end

      def has_key?
        CampusSolutions::MessageCatalog::CATALOG.fetch(key) { false }
      end
    end
  end
end

module User
  module Academics
    class TermRegistration
      include ::User::Academics::Status::Messages

      attr_reader :user
      attr_reader :term

      def initialize(user, term)
        @user = user
        @term = term
      end

      def as_json(options={})
        {
          termName: term.to_english,
          termId: term_id,
          careerCodes: career_codes,
          isInPopover: in_popover?,
          badgeCount: status_badge_count,
          status: {
            message: status_message,
            severity: status_severity,
            detailedMessageHTML: status_detailed_message_html
          },
          cnpStatus: {
            message: cnp_message,
            severity: cnp_severity,
            detailedMessageHTML: cnp_detailed_message_html
          }
        }
      end

      def tuition_calculated?
        student_attributes.any?(&:tuition_calculated?)
      end

      delegate :summer?, to: :term
      delegate :past?, to: :term
      delegate :active?, to: :term

      # Grad/law students are dropped one day AFTER the add/drop deadline.

      delegate :past_add_drop?, to: :term
      delegate :past_end_of_instruction?, to: :term
      delegate :past_financial_disbursement?, to: :term
      delegate :term_id, to: :term

      def registration_records
        @registration_records ||= user.registrations.find_by_term_id(term_id)
      end

      def student_attributes
        @student_attributes ||= user.student_attributes.find_by_term_id(term_id)
      end

      # attributes based on student-attributes

      def registered?
        student_attributes.any?(&:registered?)
      end

      def registration_service_indicator_message
        student_attributes.find(&:registered?).service_indicator_message
      end

      def cnp_exception_service_indicator_message
        student_attributes.find?(&:is_cnp_exception?).service_indicator_message
      end

      def cnp_exception?
        student_attributes.any?(&:is_cnp_exception?)
      end

      def twenty_percent_cnp_exception?
        student_attributes.any?(&:twenty_percent_cnp_exception?)
      end

      # attributes based on registration_records

      def graduate?
        registration_records.any?(&:graduate?)
      end

      def law?
        registration_records.any?(&:law?)
      end

      def undergraduate?
        registration_records.any?(&:undergraduate?)
      end

      def enrolled?
        registration_records.any?(&:enrolled?)
      end

      def career_codes
        registration_records.map(&:career_code)
      end

      def cnp_message
        cnp_status.message
      end

      def cnp_severity
        cnp_status.severity
      end

      def cnp_detailed_message_html
        cnp_status.detailed_message_html
      end

      def status_message
        return Status::Messages::MSG_NONE if summer?
        return Status::Messages::MSG_NONE unless tuition_calculated?

        career_status.message
      end

      def status_severity
        career_status.severity
      end

      def status_detailed_message_html
        career_status.detailed_message_html
      end

      def in_popover?
        return true if undergraduate?
        return true if [MSG_LIMITED_ACCESS, MSG_FEES_UNPAID, MSG_NOT_ENROLLED].include?(status_message)
        false
      end

      def popover_badge_count
        status_badge_count + cnp_badge_count
      end

      def career_status
        @career_status ||= if undergraduate?
          User::Academics::Status::Undergraduate.new(self)
        elsif graduate? && law?
          User::Academics::Status::Concurrent.new(self)
        elsif graduate? || law?
          User::Academics::Status::Postgraduate.new(self)
        end
      end

      private

      def cnp_status
        @cnp_status ||= User::Academics::Status::CancellationForNonPayment.new(self)
      end

      def status_badge_count
        in_popover? ? 1 : 0
      end

      def cnp_badge_count
        cnp_severity == ICON_WARNING ? 1 : 0
      end
    end
  end
end

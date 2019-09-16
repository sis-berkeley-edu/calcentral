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
          badgeCount: badge_count,
          isShown: shown?,
          inPopover: in_popover?,
          registrationStatus: registration_status,
          cnpStatus: cnp_status,
          calgrantStatus: calgrant_status
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
        student_attributes.find(&:is_cnp_exception?).service_indicator_message
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

      def shown?
        ![registration_status, calgrant_status, cnp_status].all? { |status| status.message.nil? }
      end

      def in_popover?
        [registration_status, calgrant_status, cnp_status].any?(&:in_popover?)
      end

      def badge_count
        [registration_status, calgrant_status, cnp_status].sum(&:badge_count)
      end

      def status_message
        registration_status.message
      end

      def registration_status
        @registration_status ||= if summer?
          null_status
        elsif !tuition_calculated?
          null_status
        elsif undergraduate?
          User::Academics::Status::Undergraduate.new(self)
        elsif graduate? && law?
          User::Academics::Status::Concurrent.new(self)
        elsif graduate? || law?
          User::Academics::Status::Postgraduate.new(self)
        end
      end

      def calgrant_status
        @calgrant_status ||= if calgrant_acknowledgement
          User::Academics::Status::CalgrantAcknowledgement.new(self)
        else
          null_status
        end
      end

      def cnp_status
        @cnp_status ||= if cnp_exception?
          User::Academics::Status::CancellationForNonPayment.new(self)
        else
          null_status
        end
      end

      def null_status
        @null_status ||= User::Academics::Status::NullStatus.new
      end

      def calgrant_acknowledgement
        @calgrant_acknowledgement ||= user.calgrant_acknowledgements.find_by_term_id(term_id)
      end
    end
  end
end

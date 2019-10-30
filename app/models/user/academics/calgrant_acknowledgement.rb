module User
  module Academics
    class CalgrantAcknowledgement
      attr_reader :id, :term_id, :status, :user

      def initialize(id:, term_id:, status:, user:)
        @id = id
        @term_id = term_id
        @status = status
        @user = user
      end

      def as_json(options = {})
        {
          id: id,
          termId: term_id,
          status: parsed_status,
        }
      end

      def title
        if complete?
          "#{link[:name]} Complete"
        else
          matching_hold&.type_description
        end
      end

      def detailed_message_html
        matching_hold&.formal_desscription if incomplete?
      end

      def complete?
        status == 'CP'
      end

      def incomplete?
        status == 'IP'
      end

      def link
        @link ||= LinkFetcher.fetch_link('UC_CX_ACTIVITY_GUIDE_CA_ENROLL', {
          'INSTANCE_ID' => id
        })
      end

      private

      def matching_hold
        @matching_hold ||= user.holds.find_by_term_id(term_id).find(&:calgrant?)
      end

      def parsed_status
        return 'Incomplete' if incomplete?
        return 'Complete' if complete?
      end
    end
  end
end

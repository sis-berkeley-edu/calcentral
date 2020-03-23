module User
  module Tasks
    class CompletedAgreement < Agreement
      attr_accessor :disable_updates_after_expiration,
        :expiration_date,
        :response,
        :response_date,
        :transaction_id,
        :title,
        :updates_forbidden,
        :visible_after_expiration,
        :aid_year

      def as_json(options={})
        super.merge({
          expiration: expiration,
          response: response,
          responseDate: responded_at.in_time_zone.to_datetime,
          title: title,
          type: 'CompletedAgreement',
          updatesAllowed: updates_allowed?,
          url: url,
          aidYear: aid_year,
        })
      end

      def url
        return if transaction_id.blank?

        @url ||= LinkFetcher.fetch_link('UC_CC_WEBMSG_AGRMNT', {
          CCI_COMM_TRANS_ID: transaction_id
        })
      end

      def updates_allowed?
        return updates_permitted? unless expired?
        update_after_expiration?
      end

      def responded_at
        response_date&.to_date
      end

      def expired?
        Date.today > expiration_date
      end

      def visible?
        return true unless expired?
        visible_after_expiration?
      end

      private

      def updates_permitted?
        updates_forbidden == 'N'
      end

      def expiration
        expiration_date&.to_date
      end

      def visible_after_expiration?
        visible_after_expiration == 'Y'
      end

      def update_after_expiration?
        disable_updates_after_expiration == 'N'
      end
    end
  end
end

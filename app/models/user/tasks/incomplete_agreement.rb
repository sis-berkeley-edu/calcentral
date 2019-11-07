module User
  module Tasks
    class IncompleteAgreement
      include ActiveModel::Model

      attr_accessor :admin_function,
        :aid_year,
        :aid_year_description,
        :description,
        :expires_on,
        :title,
        :transaction_id

      def as_json(options={})
        {
          aidYear: aid_year,
          aidYearDescription: aid_year_description,
          description: description,
          expiration: expiration,
          isExpired: expired?,
          title: title,
          type: 'IncompleteAgreement',
          url: url
        }
      end

      def expiration
        expires_on&.to_date
      end

      def expired?
        expiration < Date.today
      end

      def url
        return if transaction_id.blank?

        @url ||= LinkFetcher.fetch_link('UC_CC_AGRMNT_WEBMSG', {
          CCI_COMM_TRANS_ID: transaction_id
        })
      end
    end
  end
end

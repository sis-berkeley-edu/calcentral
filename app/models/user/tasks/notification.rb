module User
  module Tasks
    class Notification
      include ActiveModel::Model

      attr_accessor :id,
        :code,
        :category,
        :title,
        :source,
        :fixed_url,
        :status_datetime,
        :action_description,
        :user,
        :source_url,
        :admin_function,
        :institution

      def as_json
        {
          id: id,
          category: category,
          title: title,
          source: source,
          fixedUrl: fixed_url,
          statusDate: status_date,
          statusDateTime: status_datetime&.to_datetime,
          description: description,
          linkText: link_text,
          link: link
        }
      end

      def link_text
        'Read more'
      end

      def link
        LinkFetcher.fetch_link('UC_CC_WEBMSG_AGRMNT', { 'CCI_COMM_TRANS_ID' => id })
      end

      def status_date
        status_datetime&.to_date
      end

      def description
        corresponding_cs_api_message&.description
      end

      private

      def corresponding_cs_api_message
        @cs_api_message ||= user.pending_web_messages.find_by_transaction_id(id)
      end
    end
  end
end

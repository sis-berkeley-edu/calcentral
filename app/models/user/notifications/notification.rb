module User
  module Notifications
    class Notification
      include ActiveModel::Model

      attr_accessor :id,
        :code,
        :category,
        :title,
        :source,
        :fixed_url,
        :status_datetime,
        :action_text,
        :user,
        :source_url,
        :admin_function,
        :institution,
        :aid_year

      def as_json
        {
          id: id,
          type: 'UniversityNotification',
          actionText: action_text,
          category: category,
          title: title,
          source: source,
          fixedUrl: fixed_url,
          statusDate: status_date,
          statusDateTime: status_datetime&.to_datetime,
          link: link,
          isFinaid: is_finaid?,
          aidYear: aid_year,
        }
      end

      def is_finaid?
        admin_function == 'FINA'
      end

      def link
        LinkFetcher.fetch_link('UC_CC_WEBMSG_AGRMNT', { 'CCI_COMM_TRANS_ID' => id })
      end

      def status_date
        status_datetime&.to_date
      end

      # TODO: remove ::CampusSolutions::PendingMessages. That functionality is unnecessary because of this view-backed API.
      # We used to get the description from the API view but don't need it anymore.
    end
  end
end

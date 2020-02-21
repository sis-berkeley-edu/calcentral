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
          fixedUrl: use_fixed_url?,
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
        if use_fixed_url?
          LinkFetcher.fetch_link(fixed_url)
        else
          LinkFetcher.fetch_link('UC_CC_WEBMSG_AGRMNT', { 'CCI_COMM_TRANS_ID' => id })
        end
      end

      def status_date
        status_datetime&.to_date
      end

      def use_fixed_url?
        fixed_url.to_s.slice(0,5) == 'UC_CX'
      end
    end
  end
end

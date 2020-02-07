module User
  module Webcasts
    class Webcast
      include ActiveModel::Model

      attr_accessor :emitter, :id, :linkText, :source, :summary, :type, :title,
        :user_id, :date, :sourceUrl, :url

      def as_json
        {
          linkText: linkText,
          statusDate: status_date&.to_date,
          statusDateTime: status_date&.to_datetime,
          emitter: 'bCourses',
          id: "canvas_#{id}",
          source: source,
          sourceName: source,
          source_url: url,
          title: title,
          description: summary,
          type: type,
          url: url
        }
      end

      def status_date
        date.fetch(:dateTime)&.in_time_zone
      end
    end
  end
end

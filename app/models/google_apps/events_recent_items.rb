module GoogleApps
  class EventsRecentItems < Proxy

    def initialize(options = {})
      super options
      @json_filename = 'google_events_recent_items.json'
    end

    def mock_request
      super.merge(uri_matching: 'https://www.googleapis.com/calendar/v3/calendars/primary/events')
    end

    def recent_items(optional_params={})
      now = Time.zone.now
      optional_params.reverse_merge!(
        :calendar_id => 'primary',
        :max_results => 1000,
        :order_by => 'startTime',
        :single_events => true,
        :time_min => now.iso8601,
        :time_max => now.advance(:months => 1).iso8601,
        :fields => 'items(htmlLink,attendees(responseStatus,self),created,updated,creator,summary,start,end)'
      )
      optional_params.select! { |k, v| !v.nil? }
      calendar_id = optional_params.delete(:calendar_id)

      request(
        service_class: Google::Apis::CalendarV3::CalendarService,
        method_name: 'list_events',
        method_args: [calendar_id, optional_params],
        page_limiter: 1
      ).first
    end

  end
end

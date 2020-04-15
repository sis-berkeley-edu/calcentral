module GoogleApps
  class EventsList < Proxy
    require 'google/apis/calendar_v3'

    def events_list(optional_params={})
      optional_params.reverse_merge!(:calendar_id => 'primary', :max_results => 1000)
      calendar_id = optional_params.delete(:calendar_id)

      request(
        service_class: Google::Apis::CalendarV3::CalendarService,
        method_name: 'list_events',
        method_args: [calendar_id, optional_params],
        page_limiter: 2
      )
    end

    def json_filename
      page = @params[:params]['pageToken'].present? ? '_page2' : ''
      "google_events_list_#{@params[:params][:max_results]}#{page}.json"
    end

    def mock_request
      super.merge(uri_matching: 'https://www.googleapis.com/calendar/v3/calendars/primary/events')
    end
  end
end

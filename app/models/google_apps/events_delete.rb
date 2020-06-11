module GoogleApps
  class EventsDelete < Proxy
    require 'google/apis/calendar_v3'

    def initialize(options = {})
      super options
      @json_filename='google_events_delete.json'
    end

    def mock_request
      super.merge(method: :delete,
        uri_matching: 'https://www.googleapis.com/calendar/v3/calendars/primary/events')
    end

    def mock_response
      super.merge({status: 204})
    end

    def delete_event(event_id)
      request(
        service_class: Google::Apis::CalendarV3::CalendarService,
        method_name: 'delete_event',
        method_args: ['primary', event_id],
      )
    end
  end
end

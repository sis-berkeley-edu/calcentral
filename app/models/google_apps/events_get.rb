module GoogleApps
  class EventsGet < Proxy
    require 'google/apis/calendar_v3'

    def get_event(event_id)
      request(
        service_class: Google::Apis::CalendarV3::CalendarService,
        method_name: 'delete_event',
        method_args: ['primary', event_id],
      ).first
    end
  end
end

module GoogleApps
  class EventsUpdate < Proxy

    def update_event(event_id, event_body)
      request(
        service_class: Google::Apis::CalendarV3::CalendarService,
        method_name: 'update_event',
        method_args: ['primary', event_id, event_body, nil, nil, nil, false],
      ).first
    end
  end
end

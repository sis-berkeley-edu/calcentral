module UpNext
  class MyUpNext < UserSpecificModel
    include DatedFeed
    include Cache::CachedFeed
    include Cache::UserCacheExpiry
    include Cache::JsonAddedCacher
    include Cache::FilterJsonOutput

    attr_reader :begin_today, :next_day

    def init
      @begin_today = Time.zone.today.in_time_zone.to_datetime
      @next_day = begin_today.advance(:days => 1)
      self
    end

    def get_feed_internal
      up_next = {
        date: format_date(@begin_today),
        items: []
      }
      return up_next if !GoogleApps::Proxy.access_granted?(@uid)

      results = fetch_events(@uid)
      up_next[:items] = process_events(results)

      Rails.logger.debug "#{self.class.name}::get_feed: #{up_next.inspect}"
      up_next
    end

    def filter_for_view_as(feed)
      feed[:items] = []
      feed
    end

    private

    def parse_date(event_date_time)
      if event_date_time.date
        date = Date.parse(event_date_time.date.to_s).in_time_zone.to_datetime
      else
        date = DateTime.parse(event_date_time.date_time.to_s)
      end
    end

    def fetch_events(uid)
      google_proxy = GoogleApps::EventsList.new(user_id: uid)
      # Using the PoC window of beginning of today(midnight, inclusive) - tomorrow(midnight, exclusive)
      google_proxy.events_list({
        single_events: true,
        order_by: 'startTime',
        time_min: begin_today.to_formatted_s,
        time_max: next_day.to_formatted_s
      })
    end

    def is_current_all_day_event?(start)
      # The Google Calendar API will return all-day events outside the specified
      # event range.
      parse_date(start) < next_day
    end

    def handle_location(entry_location)
      location_subset = {location: ""}
      begin
        if entry_location
          location_subset[:location] = entry_location
          uri = Addressable::URI.new
          uri.query_values = {:q => entry_location}
          location_subset[:location_url] = "https://maps.google.com/maps?" + uri.query
        end
      rescue => e
        logger.warn "#{self.class.name}: #{e} - Error handling location values #{entry_location}"
        return {location: ""}
      end
      location_subset
    end


    def handle_start_end_all_day(start_date, end_date)
      result = {}
      begin
        result[:start] = format_date(parse_date(start_date))
        result[:end] = format_date(parse_date(end_date))
        if start_date.date && end_date.date
          result[:isAllDay] = true
        else
          result[:isAllDay] = false
        end
      rescue => e
        logger.warn "#{self.class.name}: #{e} - Error handling date values START_DATE=#{start_date} END_DATE=#{end_date}"
        return {}
      end
      result
    end


    def process_events(proxy_response_pages)
      day_events = []
      timed_events = []

      proxy_response_pages.each do |response_page|
        next unless response_page

        response_page.items.each do |event|
          next unless is_current_all_day_event?(event.start)
          next unless event.summary && event.summary.kind_of?(String)
          next if is_declined_event?(event)

          formatted_entry = {
            :attendees => handle_contacts(event.attendees) || [],
            :organizer => handle_contact(event.organizer) || '',
            :htmlLink => event.html_link || '',
            :status => event.status || '',
            :summary => event.summary || '',
            :hangoutLink => event.hangout_link || ''
          }

          formatted_entry.merge! handle_location(event.location)
          formatted_entry.merge! handle_start_end_all_day(event.start, event.end)

          if formatted_entry[:isAllDay]
            day_events.push(formatted_entry)
          else
            timed_events.push(formatted_entry)
          end
        end
      end

      # Sort the day events based on their summary
      day_events.sort! { |a, b| a[:summary].downcase <=> b[:summary].downcase }
      timed_events.concat(day_events)
    end

    def handle_contact(contact)
      if contact.try(:display_name).present?
        contact.display_name
      elsif contact.try(:email).present?
        contact.email
      end
    end

    def handle_contacts(contacts)
      return unless contacts.try(:any?)
      contacts.map { |contact| handle_contact(contact) }.compact
    end

    def is_declined_event?(event)
      event && event.attendees &&
        (event.attendees.index { |attendee|
          attendee.self? == true && attendee.response_status == 'declined'
        })
    end

  end
end

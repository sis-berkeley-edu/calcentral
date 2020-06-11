require 'mail'

module MyBadges
  class GoogleCalendar
    include MyBadges::BadgesModule, DatedFeed, ClassLogger

    def initialize(uid)
      @uid = uid
      @count_limiter = 25
    end

    def fetch_counts(params = {})
      @google_mail ||= User::Oauth2Data.get_google_email(@uid)
      @rewrite_url ||= !(Mail::Address.new(@google_mail).domain =~ /berkeley.edu/).nil?
      internal_fetch_counts params
    end

    private

    # Because normal google accounts are in a separate domain from berkeley.edu google accounts,
    # there are issues with multiple logged in google sessions which triggers some rather unrecoverable
    # errors on when clicking off to the remote link. This should help with the problem by enforcing
    # a specific domain restriction, based on the stored oauth token. See CLC-1765
    # (https://jira.media.berkeley.edu/jira/browse/CLC-1765) and
    # CLC-1762 (https://jira.media.berkeley.edu/jira/browse/CLC-1762)
    def handle_url(url_link)
      return url_link unless @rewrite_url
      query_params = Rack::Utils.parse_query(URI.parse(url_link).query)
      if (eid = query_params["eid"]).blank?
        logger.warn "unable to parse eid from htmlLink #{url_link}"
        url_link
      else
        "https://calendar.google.com/a/berkeley.edu?eid=#{eid}"
      end
    end

    def internal_fetch_counts(params = {})
      google_proxy = GoogleApps::EventsRecentItems.new(user_id: @uid)
      google_calendar_results = google_proxy.recent_items(params)
      modified_entries = {}
      modified_entries[:items] = []
      modified_entries[:count] = 0

      google_calendar_results.items.each do |event|
        next if event.summary.blank?
        next unless is_unconfirmed_event? event

        if modified_entries[:count] < @count_limiter
          begin
            entry = {
              :link => handle_url(event.html_link),
              :title => event.summary,
              :startTime => verify_and_format_date_time(event.start),
              :endTime => verify_and_format_date_time(event.end),
              :modifiedTime => format_date(event.updated.to_datetime),
              :allDayEvent => is_all_day_event?(event),
            }
            entry.merge! event_state_fields(event)
            modified_entries[:items] << entry
          rescue => e
            logger.warn "could not process entry: #{entry} - #{e}"
            next
          end
        end
        modified_entries[:count] += 1
      end

      modified_entries
    end

    def is_all_day_event?(event)
      # Should be present if an all day event
      # https://github.com/googleapis/google-api-ruby-client/blob/0.24.1/generated/google/apis/calendar_v3/classes.rb#L1741,L1744
      event.start.date.present?
    end

    def verify_and_format_date_time(date_obj)
      return {} unless date_obj && (date_obj.date_time || date_obj.date)
      if date_obj.date_time
        return format_date(date_obj.date_time.to_datetime)
      else
        return {
          :allDayEvent => true
        }.merge format_date(date_obj.date.to_datetime)
      end
    end

    def event_state_fields(event)
      # Ignore fractional second precision
      if event.created.to_i == event.updated.to_i
        new_entry_hash = {}
        #only use new if the author != self
        if (event.creator && event.creator.email &&
          event.creator.display_name && event.creator.email != @google_mail)
          new_entry_hash[:changeState] = 'new'
          new_entry_hash[:editor] = event.creator.display_name if event.creator.display_name
        else
          new_entry_hash[:changeState] = 'created'
        end
        new_entry_hash
      else
        { :changeState => "updated" }
      end
    end

    def is_unconfirmed_event?(event)
      event && event.attendees &&
        (event.attendees.select {|attendee|
          attendee.self? && attendee.response_status == 'needsAction'
        }).present?
    end
  end
end

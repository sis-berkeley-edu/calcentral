module Concerns
  module DatesAndTimes
    extend self

    # Campus Solutions will send a date string (ex. 23-MAY-16) that Rails incorrectly parses as a UTC Time object.  We want the time casted to Pacific with the same time preserved, so that other time zones will
    # automatically convert to the correct time relative to Berkeley's Pacific time zone
    def cast_utc_to_pacific(utc_time)
      # Depending on the time of the year, we can either be in Pacific Daylight Time or Pacific Standard Time
      time_zone = Time.zone.now.zone
      Time.parse(utc_time.strftime("%Y-%m-%d %H:%M:%S #{time_zone}"))
    end

  end
end

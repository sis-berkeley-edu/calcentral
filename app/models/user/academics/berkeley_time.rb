module User::Academics::BerkeleyTime
  # The datetime strings that come from many APIs are unzoned, but are treated
  # as Pacific Time Zone, e.g. 2020-09-16T23:59:00 means
  # Sept 16 2020 at 11:59PM Pacific. When the front-end parses those dates, it
  # assumes to parse them in the browser's local time-time. When attempting to
  # format them for the user... hijinks ensue.
  #
  # This method returns an ISO-8601 date string (The Right Date Format™)
  # with the correct time zone offset so parsing and then casting to Pacific
  # returns the expected result.
  def zoned(time)
    time.in_time_zone("Pacific Time (US & Canada)").iso8601 if time
  end
end

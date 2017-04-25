module MyAcademics
  module GradingModule
    extend self

    LAW_2168 = "Law Fall 2016"
    LAW_2172 = "Law Spring 2017"
    GEN_2168 = "General Fall 2016"
    GEN_MID_2172 = "General Midpoint Spring 2017"
    GEN_FIN_2172 = "General Final Spring 2017"


    def grading_status_mapping
      {
        noCsData: {
          beforeGradingPeriod: :periodNotStarted,
          inGradingPeriod: :periodNotStarted,
          afterGradingPeriod: :periodNotStarted,
          gradingPeriodNotSet: :periodNotStarted
        },
        GRD: {
          beforeGradingPeriod: :periodStarted,
          inGradingPeriod: :periodStarted,
          afterGradingPeriod: :gradesOverdue,
          gradingPeriodNotSet: :periodStarted
        },
        POST: {
          beforeGradingPeriod:  :gradesPosted,
          inGradingPeriod:  :gradesPosted,
          afterGradingPeriod:  :gradesPosted,
          gradingPeriodNotSet:  :gradesPosted
        },
        RDY: {
          beforeGradingPeriod:  :gradesApproved,
          inGradingPeriod:  :gradesApproved,
          afterGradingPeriod:  :gradesApproved,
          gradingPeriodNotSet:  :gradesApproved
        },
        NRVW: {
          beforeGradingPeriod: :periodNotStarted,
          inGradingPeriod: :periodStarted,
          afterGradingPeriod: :periodStarted,
          gradingPeriodNotSet: :periodStarted
        },
        # Approved midpoint grades will mimic posted grade behavior on the front-end
        APPR: {
          beforeGradingPeriod:  :gradesPosted,
          inGradingPeriod:  :gradesPosted,
          afterGradingPeriod:  :gradesPosted,
          gradingPeriodNotSet:  :gradesPosted
        }
      }
    end

    def summer_law_session_mapping
      {
        "1" => :Q3,
        "6W1" => :Q4,
        "6W2" => :Q4,
        "8W" => :Q4,
        "10W" => :Q4,
        "Q1" => :Q1,
        "Q2" => :Q2,
        "Q3" => :Q3,
        "Q4" => :Q4
      }
    end

    def has_law?(semester_classes)
      !!semester_classes.try(:find) do |semester_class|
        semester_class[:dept].present? && semester_class[:dept] == 'LAW'
      end
    end

    def has_general?(semester_classes)
      !!semester_classes.try(:find) do |semester_class|
        semester_class[:dept].present? && semester_class[:dept] != 'LAW'
      end
    end

    def is_law_class?(semester_class)
      if semester_class.try(:[], :dept) == 'LAW'
        return true
      else
        return false
      end
    end

    def is_summer_class?(term_id)
      Berkeley::TermCodes.edo_id_is_summer?(term_id)
    end

    def is_summer_semester?(semester)
      semester[:termCode] == 'C'
    end

    def is_primary_section?(section)
      if section.try(:[], :is_primary_section) == true
        return true
      else
        return false
      end
    end

    def format_period_start(start_date)
      start_date.to_date.strftime('%b %d')
    end

    def format_period_end(end_date)
      return end_date.to_date.strftime('%b %d') if DateTime.now.year == end_date.to_date.year
      end_date.to_date.strftime('%b %d, %Y')
    end

    def format_period_start_summer(start_date)
      start_date.to_date.strftime('%m/%d')
    end

    def format_period_end_summer(end_date)
      return end_date.to_date.strftime('%m/%d') if DateTime.now.year == end_date.to_date.year
      end_date.to_date.strftime('%m/%d/%Y')
    end

    def unexpected_cs_status?(cs_grading_status, is_law)
      has_error = false
      if cs_grading_status.nil? || final_status_error?(cs_grading_status) || (!is_law && midpoint_status_error?(cs_grading_status))
        has_error = true
      end
      has_error
    end

    def final_status_error?(cs_grading_status)
      !(!!%w{GRD RDY APPR POST}.find { |s| s == cs_grading_status.try(:[],:finalStatus) } || cs_grading_status.try(:[], :finalStatus).blank?)
    end

    def midpoint_status_error?(cs_grading_status)
      !(!!%w{APPR NRVW RDY}.find { |s| s== cs_grading_status.try(:[], :midpointStatus) } || cs_grading_status.try(:[],:midpointStatus).blank?)
    end

    def valid_grading_period?(is_law, term_id)
      # Use class level var to reduce noise in log on invalid grading period
      return @valid_grading_period if !is_law  && @valid_grading_period.present?
      return @valid_grading_period_law if is_law && @valid_grading_period_law.present?
      @valid_grading_period = valid_grading_period_dates?(is_law, term_id) unless is_law
      @valid_grading_period_law = valid_grading_period_dates?(is_law, term_id) if is_law
      is_law ? @valid_grading_period_law : @valid_grading_period
    end

    def valid_grading_period_dates?(is_law, term_id)
      return false if period_dates_bad_format?(is_law, term_id)
      return false if period_dates_bad_order?(is_law, term_id)
      true
    end

    def period_dates_bad_format?(is_law, term_id)
      if is_law
        if term_id == '2168'
          return dates_badly_formatted?(grading_period.dates.law.fall_2016, LAW_2168)
        elsif term_id == '2172'
          return dates_badly_formatted?(grading_period.dates.law.spring_2017, LAW_2172)
        else
          return true
        end
      else
        if term_id == '2168'
          return dates_badly_formatted?(grading_period.dates.general.fall_2016, GEN_2168)
        elsif term_id == '2172'
          return dates_badly_formatted?(grading_period.dates.general.spring_2017.midpoint, GEN_MID_2172) ||
            dates_badly_formatted?(grading_period.dates.general.spring_2017.final, GEN_FIN_2172)
        else
          return true
        end
      end
    end

    def period_dates_bad_order?(is_law, term_id)
      if is_law
        if term_id == '2168'
          return dates_out_of_order?(grading_period.dates.law.fall_2016, LAW_2168)
        elsif term_id == '2172'
          return dates_out_of_order?(grading_period.dates.law.spring_2017, LAW_2172)
        else
          return true
        end
      else
        if term_id == '2168'
          return dates_out_of_order?(grading_period.dates.general.fall_2016, GEN_2168)
        elsif term_id == '2172'
          return dates_out_of_order?(grading_period.dates.general.spring_2017.midpoint, GEN_MID_2172) ||
            dates_out_of_order?(grading_period.dates.general.spring_2017.final, GEN_FIN_2172)
        else
          return true
        end
      end
    end

    def dates_badly_formatted?(dates, datetype)
      dates.try(:each_value) do |date|
        begin
          DateTime.parse(date.to_s)
        rescue
          logger.error "Bad Format for Grading Period #{datetype} in Settings for Class #{self.class.name} feed, uid = #{@uid}"
          return true
        end
      end
      false
    end

    def dates_out_of_order?(dates, datetype)
      begin
        if DateTime.parse(dates.start.to_s) >= DateTime.parse(dates.end.to_s)
          logger.error "Grading Period start after end for #{datetype} in Settings for Class #{self.class.name} feed, uid = #{@uid}"
          return true
        end
      rescue
        logger.error "Grading Period dates errored out for #{datetype} in Settings for Class #{self.class.name} feed, uid = #{@uid}"
        return true
      end
      false
    end

    # Campus Solutions will send a date string (ex. 23-MAY-16) that Rails incorrectly parses as a UTC Time object.  We want the time casted to Pacific with the same time preserved, so that other time zones will
    # automatically convert to the correct time relative to Berkeley's Pacific time zone
    def cast_utc_to_pacific(utc_time)
      # Depending on the time of the year, we can either be in Pacific Daylight Time or Pacific Standard Time
      time_zone = Time.zone.now.zone
      Time.parse(utc_time.strftime("%Y-%m-%d %H:%M:%S #{time_zone}"))
    end

  end
end

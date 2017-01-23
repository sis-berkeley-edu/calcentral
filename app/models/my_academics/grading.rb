module MyAcademics
  class Grading < UserSpecificModel

    def merge(data)
      teaching_semesters = data[:teachingSemesters]
      if teaching_semesters
        add_grading_to_semesters(teaching_semesters)
      end
    end

    def grading_status_mapping
      {
        noCsData: {
          beforeGradingPeriod: :periodNotStarted,
          inGradingPeriod: :periodNotStarted,
          afterGradingPeriod: :periodNotStarted,
          gradingPeriodNotSet: :periodNotStarted
        },
        GRD: {
          beforeGradingPeriod: :periodNotStarted,
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

    def add_grading_to_semesters(teaching_semesters)
      teaching_semesters.try(:each) do |semester|
        term_code = Berkeley::TermCodes.slug_to_edo_id(semester[:slug])
        add_grading_header(semester, term_code)  if has_general?(semester[:classes])
        add_grading_header_law(semester, term_code) if has_law?(semester[:classes])
        add_grading_to_classes(semester[:classes], term_code)
       end
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

    def add_grading_header(semester, term_code)
      # This is a temp fix for Fall 2016 & Spring 2017 hardcoded from settings
      fall_dates = grading_period.dates.general.fall_2016
      spring_dates = grading_period.dates.general.spring_2017
      if (term_code == '2168' || term_code == '2172') && valid_grading_period?(false, term_code)
        semester.merge!(
          {
            gradingAssistanceLinkMidpoint: term_code == '2172' ? grading_period.links.midpoint : nil,
            gradingAssistanceLink:  grading_period.links.final,
            gradingPeriodMidpointStart: term_code == '2172' ? format_period_start(spring_dates.midpoint.start) : nil,
            gradingPeriodMidpointEnd: term_code == '2172' ? format_period_end(spring_dates.midpoint.end) : nil,
            gradingPeriodFinalStart: term_code == '2172' ? format_period_start(spring_dates.final.start) : format_period_start(fall_dates.start),
            gradingPeriodFinalEnd:  term_code == '2172' ? format_period_end(spring_dates.final.end) : format_period_end(fall_dates.end)
          })
      else
        semester.merge!(
          {
            gradingAssistanceLinkMidpoint: grading_period.links.midpoint,
            gradingAssistanceLink:  grading_period.links.final,
            gradingPeriodMidpointStart: nil,
            gradingPeriodMidpointEnd: nil,
            gradingPeriodFinalStart: nil,
            gradingPeriodFinalEnd: nil
          })
      end
    end

    def add_grading_header_law(semester, term_code)
      # This is a temp fix for Fall 2016 & Spring 2017 hardcoded from settings
      # Law courses do not participate in midpoint grading
      fall_dates = grading_period.dates.law.fall_2016
      spring_dates = grading_period.dates.law.spring_2017
      if (term_code == '2168' || term_code == '2172') && valid_grading_period?(true, term_code)
        semester.merge!(
          {
            gradingAssistanceLinkLaw:  grading_period.links.law,
            gradingPeriodStartLaw: term_code == '2172' ? format_period_start(spring_dates.start) : format_period_start(fall_dates.start),
            gradingPeriodEndLaw: term_code == '2172' ? format_period_end(spring_dates.end) : format_period_end(fall_dates.end)
          })
      else
        semester.merge!(
          {
            gradingAssistanceLinkLaw:  grading_period.links.law,
            gradingPeriodStartLaw: nil,
            gradingPeriodEndLaw: nil
          })
      end
    end

    def format_period_start(start_date)
      start_date.to_date.strftime('%b %d')
    end

    def format_period_end(end_date)
      return end_date.to_date.strftime('%b %d') if DateTime.now.year == end_date.to_date.year
      end_date.to_date.strftime('%b %d, %Y')
    end

    def add_grading_to_classes(semester_classes, term_code)
      semester_classes.try(:each) do |semester_class|
        add_grading_to_class(semester_class, term_code)
      end
    end

    def add_grading_to_class(semester_class, term_code)
      is_law = semester_class.try(:[],:dept) == 'LAW'
      semester_class.try(:[],:sections).try(:each) do |section|
        ccn = section[:ccn]
        has_grading_access = has_grading_access?(section)
        cs_grading_status = parse_cs_grading_status(get_cs_status(ccn, is_law, term_code), is_law)
        if is_law
          section.merge!(
            {
              csGradingStatus: section[:is_primary_section] ? cs_grading_status[:finalStatus] : nil,
              ccGradingStatus: section[:is_primary_section] && has_grading_access ? parse_cc_grading_status(cs_grading_status[:finalStatus], is_law, false, term_code): nil,
              gradingLink: section[:is_primary_section] && has_grading_access ? get_grading_link(ccn, term_code, true, cs_grading_status) : nil
            })
        else
          section.merge!(
            {
              csMidpointGradingStatus: section[:is_primary_section] ? cs_grading_status[:midpointStatus] : nil,
              ccMidpointGradingStatus: section[:is_primary_section] && has_grading_access ? parse_cc_grading_status(cs_grading_status[:midpointStatus], is_law, true, term_code) : nil,
              csGradingStatus: section[:is_primary_section] ? cs_grading_status[:finalStatus] : nil,
              ccGradingStatus: section[:is_primary_section] && has_grading_access ? parse_cc_grading_status(cs_grading_status[:finalStatus], is_law, false, term_code): nil,
              gradingLink: section[:is_primary_section] && has_grading_access ? get_grading_link(ccn, term_code, false, cs_grading_status) : nil
            })
        end
      end
    end

    def has_grading_access?(section)
      !!section[:instructors].try(:find) do |instructor|
        instructor[:uid] == @uid && instructor[:ccGradingAccess] != :noGradeAccess
      end
    end

    def get_grading_link(ccn, term_code, is_law, cs_grading_status)
      return nil unless ccn && term_code
      grading_link = AcademicsModule::fetch_link('UC_CX_SSS_GRADE_ROSTER', { STRM: term_code, CLASS_NBR: ccn, INSTITUTION: 'UCB01' })
      return grading_link if cs_grading_status[:finalStatus] != :noCsData
      if !is_law && cs_grading_status.key?(:midpointStatus)
        return grading_link if cs_grading_status[:midpointStatus] != :noCsData
      end
    end

    def get_cs_status(ccn, is_law, term_code)
      cnn_status = nil
      if (grading_feed = get_grading_data)
        grading_statuses = grading_feed[:feed].try(:[],:ucSrClassGrading).try(:[],:classGradingStatuses)
        cnn_status = find_ccn_grading_statuses(grading_statuses, ccn, is_law, term_code)
      end
      cnn_status
    end

    def get_grading_data
      @grading_feed ||= CampusSolutions::Grading.new(user_id: @uid).get
    end

    def find_ccn_grading_statuses(grading_statuses, ccn, is_law, term_code)
      return nil unless grading_statuses && ccn && term_code
      status_array  = grading_statuses.try(:[], :classGradingStatus)
      # if feed returned single status it will not be wrapped in array
      # need to wrap in array for code to iterate correctly
      status_array =  status_array.blank? || status_array.kind_of?(Array) ? status_array : [] << status_array
      rosters = status_array.try(:find) do |grading_status|
        grading_status[:strm] == term_code && grading_status[:classNbr] == ccn
      end.try(:[],:roster)
      find_status_in_rosters(rosters, is_law)
    end

    def find_status_in_rosters(rosters, is_law)
      # if feed returned single roster it will not be wrapped in array
      # need to wrap in array for code to iterate correctly
      roster_array = rosters.blank? || rosters.kind_of?(Array) ? rosters : [] << rosters
      final_status = roster_array.try(:find) do |r|
        r[:gradeRosterTypeCode].present? && r[:gradeRosterTypeCode] == 'FIN'
      end.try(:[],:gradingStatusCode)
      # Since law courses do not participate in midpoint grading, we don't have to look for any midpoint grade rosters.
      return {finalStatus: final_status} if is_law
      midpoint_status = roster_array.try(:find) do |r|
        r[:gradeRosterTypeCode].present? && r[:gradeRosterTypeCode] == 'MID'
      end.try(:[], :grApprovalStatusCode)
      {
        midpointStatus: midpoint_status,
        finalStatus: final_status
      }
    end

    def parse_cs_grading_status(cs_grading_status, is_law)
      return :noCsData if unexpected_cs_status?(cs_grading_status, is_law)
      cs_grading_status[:finalStatus] = case cs_grading_status[:finalStatus]
        when 'GRD'
          :GRD
        when 'POST'
          :POST
        when 'RDY'
          :RDY
        else
          :noCsData
      end
      if !is_law
        cs_grading_status[:midpointStatus] = case cs_grading_status[:midpointStatus]
          when 'APPR'
            :APPR
          when 'NRVW', 'RDY'
            :NRVW
           else
            :noCsData
        end
      end
      cs_grading_status
    end

    def parse_cc_grading_status(cs_grading_status, is_law, is_midpoint, term_code)
      grading_period_status = get_grading_period_status(is_law, is_midpoint, term_code)
      grading_status_mapping[cs_grading_status][grading_period_status]
    end

    def unexpected_cs_status?(cs_grading_status, is_law)
      return false if !!%w{GRD RDY APPR POST}.find { |s| s == cs_grading_status[:finalStatus] } || cs_grading_status[:finalStatus].blank?
      if !is_law
        return false if !!%w{APPR NRVW RDY}.find { |s| s == cs_grading_status[:midpointStatus] } || cs_grading_status[:midpointStatus].blank?
      end
      logger.debug "Unexpected CS Final Grading Status Received (Final: #{cs_grading_status[:finalStatus]}#{', Midpoint: ' + cs_grading_status[:midpointStatus] if cs_grading_status.key?(:midpointStatus)}) for Class #{self.class.name} feed, uid = #{@uid}"
      true
    end

    def get_grading_period_status(is_law, is_midpoint, term_code)
      return :gradingPeriodNotSet unless valid_grading_period?(is_law, term_code)
      if is_law
        if term_code == '2168'
          return find_grading_period_status(grading_period.dates.law.fall_2016)
        elsif term_code == '2172'
          return find_grading_period_status(grading_period.dates.law.spring_2017)
        end
      elsif !is_law
        if term_code == '2168'
          return find_grading_period_status(grading_period.dates.general.fall_2016)
        elsif term_code == '2172'
          if is_midpoint
            return find_grading_period_status(grading_period.dates.general.spring_2017.midpoint)
          else
            return find_grading_period_status(grading_period.dates.general.spring_2017.final)
          end
        end
      end
    end

    def find_grading_period_status(dates)
      current_date = Settings.terms.fake_now || DateTime.now
      return :beforeGradingPeriod if current_date < DateTime.parse(dates.start.to_s)
      return :afterGradingPeriod if current_date > DateTime.parse(dates.end.to_s)
      return :inGradingPeriod
    end

    def valid_grading_period?(is_law, term_code)
      # Use class level var to reduce noise in log on invalid grading period
      return @valid_grading_period if !is_law  && @valid_grading_period.present?
      return @valid_grading_period_law if is_law && @valid_grading_period_law.present?
      @valid_grading_period = check_grading_period?(is_law, term_code) unless is_law
      @valid_grading_period_law = check_grading_period?(is_law, term_code) if is_law
      is_law ? @valid_grading_period_law : @valid_grading_period
    end

    def check_grading_period?(is_law, term_code)
      return false if period_dates_bad_format?(is_law, term_code)
      return false if period_dates_not_set?(is_law, term_code)
      return false if period_dates_bad_order?(is_law, term_code)
      true
    end

    def period_dates_not_set?(is_law, term_code)
      if is_law
        if term_code == '2168'
          return dates_are_blank?(grading_period.dates.law.fall_2016, 'Law Fall 2016')
        elsif term_code == '2172'
          return dates_are_blank?(grading_period.dates.law.spring_2017, 'Law Spring 2017')
        else
          return true
        end
      else
        if term_code == '2168'
          return dates_are_blank?(grading_period.dates.general.fall_2016, 'General Fall 2016')
        elsif term_code == '2172'
          return dates_are_blank?(grading_period.dates.general.spring_2017.midpoint, 'General Midpoint Spring 2017') ||
                 dates_are_blank?(grading_period.dates.general.spring_2017.final, 'General Final Spring 2017')
        else
          return true
        end
      end
    end

    def period_dates_bad_format?(is_law, term_code)
      if is_law
        if term_code == '2168'
          return dates_badly_formatted?(grading_period.dates.law.fall_2016, 'Law Fall 2016')
        elsif term_code == '2172'
          return dates_badly_formatted?(grading_period.dates.law.spring_2017, 'Law Spring 2017')
        else
          return true
        end
      else
        if term_code == '2168'
          return dates_badly_formatted?(grading_period.dates.general.fall_2016, 'General Fall 2016')
        elsif term_code == '2172'
          return dates_badly_formatted?(grading_period.dates.general.spring_2017.midpoint, 'General Midpoint Spring 2017') ||
            dates_badly_formatted?(grading_period.dates.general.spring_2017.final, 'General Final Spring 2017')
        else
          return true
        end
      end
    end

    def period_dates_bad_order?(is_law, term_code)
      if is_law
        if term_code == '2168'
          return dates_out_of_order?(grading_period.dates.law.fall_2016, 'Law Fall 2016')
        elsif term_code == '2172'
          return dates_out_of_order?(grading_period.dates.law.spring_2017, 'Law Spring 2017')
        else
          return true
        end
      else
        if term_code == '2168'
          return dates_out_of_order?(grading_period.dates.general.fall_2016, 'General Fall 2016')
        elsif term_code == '2172'
          return dates_out_of_order?(grading_period.dates.general.spring_2017.midpoint, 'General Midpoint Spring 2017') ||
            dates_out_of_order?(grading_period.dates.general.spring_2017.final, 'General Final Spring 2017')
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

    def dates_are_blank?(dates, datetype)
      dates.each_value do |date|
        if (date.blank?)
          logger.error "No date set for Grading Period #{datetype} in Settings for Class #{self.class.name} feed, uid = #{@uid}"
        end
        return true
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

    def grading_period
      @grading_period ||= Settings.grading_period
    end

  end
end

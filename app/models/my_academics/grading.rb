module MyAcademics
  class Grading < UserSpecificModel
    include GradingModule
    include LinkFetcher

    #TODO: Starting Fall 2017, replace this with an array of the current term + the three previous terms.
    ACTIVE_GRADING_TERMS = ['2168', '2172', '2175']

    def merge(data)
      teaching_semesters = data[:teachingSemesters]
      if teaching_semesters
        add_grading_to_semesters(teaching_semesters)
      end
    end

    def add_grading_to_semesters(teaching_semesters)
      teaching_semesters.try(:each) do |semester|
        term_id = Berkeley::TermCodes.slug_to_edo_id(semester[:slug])
        add_grading_links semester
        if ACTIVE_GRADING_TERMS.include? term_id
          if is_summer_semester? semester
            add_grading_dates_summer(semester[:classes])
          else
            add_grading_dates(semester, term_id)  if has_general?(semester[:classes])
            add_grading_dates_law(semester, term_id) if has_law?(semester[:classes])
          end
        end
        add_grading_to_classes(semester[:classes], term_id)
      end
    end

    def add_grading_links(semester)
      if has_general?(semester[:classes])
        # A termCode of 'C' denotes a summer term.  Every non-law term has midpoint grading, except summer.
        if is_summer_semester? semester
          semester.merge!(
            {
              gradingAssistanceLink: grading_period.links.final
            })
        else
          semester.merge!(
            {
              gradingAssistanceLinkMidpoint: grading_period.links.midpoint,
              gradingAssistanceLink: grading_period.links.final
            }
          )
        end
      end
      if has_law?(semester[:classes])
        semester.merge!(
          {
            gradingAssistanceLinkLaw: grading_period.links.law
          })
      end
    end

    def add_grading_dates(semester, term_id)
      # This is a temp fix for Fall 2016 & Spring 2017 hardcoded from settings
      fall_dates = grading_period.dates.general.fall_2016
      spring_dates = grading_period.dates.general.spring_2017
      if (term_id == '2168' || term_id == '2172') && valid_grading_period?(false, term_id)
        semester.merge!(
          {
            gradingPeriodMidpointStart: term_id == '2172' ? format_period_start(spring_dates.midpoint.start) : nil,
            gradingPeriodMidpointEnd: term_id == '2172' ? format_period_end(spring_dates.midpoint.end) : nil,
            gradingPeriodFinalStart: term_id == '2172' ? format_period_start(spring_dates.final.start) : format_period_start(fall_dates.start),
            gradingPeriodFinalEnd:  term_id == '2172' ? format_period_end(spring_dates.final.end) : format_period_end(fall_dates.end)
          })
      else
        semester.merge!(
          {
            gradingPeriodMidpointStart: nil,
            gradingPeriodMidpointEnd: nil,
            gradingPeriodFinalStart: nil,
            gradingPeriodFinalEnd: nil
          })
      end
    end

    def add_grading_dates_law(semester, term_id)
      # This is a temp fix for Fall 2016 & Spring 2017 hardcoded from settings
      # Law courses do not participate in midpoint grading
      fall_dates = grading_period.dates.law.fall_2016
      spring_dates = grading_period.dates.law.spring_2017
      if (term_id == '2168' || term_id == '2172') && valid_grading_period?(true, term_id)
        semester.merge!(
          {
            gradingPeriodStartLaw: term_id == '2172' ? format_period_start(spring_dates.start) : format_period_start(fall_dates.start),
            gradingPeriodEndLaw: term_id == '2172' ? format_period_end(spring_dates.end) : format_period_end(fall_dates.end)
          })
      else
        semester.merge!(
          {
            gradingPeriodStartLaw: nil,
            gradingPeriodEndLaw: nil
          })
      end
    end

    def add_grading_dates_summer(semester_classes)
      semester_classes.try(:each) do |semester_class|
        semester_class.try(:[], :sections).try(:each) do |section|
          if is_primary_section? section
            if is_law_class? semester_class
              add_grading_dates_summer_law(semester_class, section)
            else
              add_grading_dates_summer_general(semester_class, section)
            end
          end
        end
      end
    end

    def add_grading_dates_summer_law(semester_class, section)
      if section.try(:[], :session_id)
        mapped_session_id = summer_law_session_mapping[section[:session_id]]
        section.merge!({
          mappedSessionId: mapped_session_id,
          gradingPeriodStartDate: grading_period.dates.law.summer_2017.send(mapped_session_id).start,
          gradingPeriodEndDate: grading_period.dates.law.summer_2017.send(mapped_session_id).end,
          gradingPeriodEndDateFormatted: format_period_end_summer(grading_period.dates.law.summer_2017.send(mapped_session_id).end).to_s
        })
      else
        logger.error "No session ID found for section #{section[:ccn]}, course ID #{semester_class[:course_id]}"
      end
    end

    def add_grading_dates_summer_general(semester_class, section)
      if section.try(:[], :end_date)
        grading_start = cast_utc_to_pacific(section[:end_date] - 4.days)
        grading_end = cast_utc_to_pacific(section[:end_date] + 8.days + 23.hours + 59.minutes + 59.seconds)
        # Summer general grading periods are specific to the class start/end dates.
        section.merge!(
          {
            gradingPeriodStartDate: grading_start,
            gradingPeriodEndDate: grading_end,
            gradingPeriodEndDateFormatted: format_period_end_summer(grading_end).to_s
          })
      else
        logger.error "No end date found for section #{section[:ccn]}, course ID #{semester_class[:course_id]}"
      end
    end

    def add_grading_to_classes(semester_classes, term_id)
      semester_classes.try(:each) do |semester_class|
        add_grading_to_class(semester_class, term_id)
      end
    end

    def add_grading_to_class(semester_class, term_id)
      is_law = is_law_class? semester_class
      is_summer = is_summer_class? term_id
      semester_class.try(:[],:sections).try(:each) do |section|
        # Only primary sections have grade rosters.
        if is_primary_section? section
          # Only parse grading status for the active grading terms.
          if ACTIVE_GRADING_TERMS.include? term_id
            ccn = section[:ccn]
            has_grade_access = has_grading_access?(section)
            cs_grading_status = parse_cs_grading_status(get_cs_status(ccn, is_law, term_id), is_law, is_summer)
            # Law and summer classes do not have midpoint grades.
            if is_law && !is_summer
              section.merge!(
                {
                  csGradingStatus: cs_grading_status[:finalStatus],
                  ccGradingStatus: has_grade_access ? parse_cc_grading_status(cs_grading_status[:finalStatus], is_law, false, term_id) : nil
                })
            elsif is_summer
              section.merge!(
                {
                  csGradingStatus: cs_grading_status[:finalStatus],
                  ccGradingStatus: has_grade_access ? parse_cc_grading_status_summer(section, cs_grading_status[:finalStatus], term_id) : nil
                })
            else
              section.merge!(
                {
                  csMidpointGradingStatus: cs_grading_status[:midpointStatus],
                  ccMidpointGradingStatus: has_grade_access ? parse_cc_grading_status(cs_grading_status[:midpointStatus], is_law, true, term_id) : nil,
                  csGradingStatus: cs_grading_status[:finalStatus],
                  ccGradingStatus: has_grade_access ? parse_cc_grading_status(cs_grading_status[:finalStatus], is_law, false, term_id) : nil
                })
            end
          end
          # We want to include the link to the grading roster if it exists, without regard for status or whether it's an active grading term
          section.merge!(
            {
              gradingLink: has_grade_access ? get_grading_link(ccn, term_id, cs_grading_status) : nil
            })
        end
      end
    end

    def has_grading_access?(section)
      !!section[:instructors].try(:find) do |instructor|
        instructor[:uid].try(:to_i) == @uid.try(:to_i) && instructor.try(:[], :ccGradingAccess) != :noGradeAccess
      end
    end

    def get_grading_link(ccn, term_code, cs_grading_status)
      return nil unless ccn && term_code
      grading_link = fetch_link('UC_CX_SSS_GRADE_ROSTER', { STRM: term_code, CLASS_NBR: ccn, INSTITUTION: 'UCB01' })
      return grading_link if cs_grading_status[:finalStatus] != :noCsData
      if cs_grading_status.key?(:midpointStatus)
        return grading_link if cs_grading_status[:midpointStatus] != :noCsData
      end
    end

    def get_cs_status(ccn, is_law, term_id)
      cnn_status = nil
      if (grading_feed = get_grading_data)
        grading_statuses = grading_feed.try(:[],:feed).try(:[],:ucSrClassGrading).try(:[],:classGradingStatuses)
        cnn_status = find_ccn_grading_statuses(grading_statuses, ccn, is_law, term_id)
      end
      cnn_status
    end

    def get_grading_data
      @grading_feed ||= CampusSolutions::Grading.new(user_id: @uid).get
    end

    def find_ccn_grading_statuses(grading_statuses, ccn, is_law, term_id)
      return nil unless grading_statuses && ccn && term_id
      is_summer = is_summer_class? term_id
      status_array  = grading_statuses.try(:[], :classGradingStatus)
      # if feed returned single status it will not be wrapped in array
      # need to wrap in array for code to iterate correctly
      status_array =  status_array.blank? || status_array.kind_of?(Array) ? status_array : [] << status_array
      rosters = status_array.try(:find) do |grading_status|
        grading_status[:strm] == term_id && grading_status[:classNbr] == ccn
      end.try(:[],:roster)
      find_status_in_rosters(rosters, is_law, is_summer)
    end

    def find_status_in_rosters(rosters, is_law, is_summer)
      # if feed returned single roster it will not be wrapped in array
      # need to wrap in array for code to iterate correctly
      roster_array = rosters.blank? || rosters.kind_of?(Array) ? rosters : [] << rosters
      final_status = roster_array.try(:find) do |r|
        r[:gradeRosterTypeCode].present? && r[:gradeRosterTypeCode] == 'FIN'
      end.try(:[],:gradingStatusCode)
      # Since law and summer courses do not participate in midpoint grading, we don't have to look for any midpoint grade rosters.
      return {finalStatus: final_status} if (is_law || is_summer)
      midpoint_status = roster_array.try(:find) do |r|
        r[:gradeRosterTypeCode].present? && r[:gradeRosterTypeCode] == 'MID'
      end.try(:[], :grApprovalStatusCode)
      {
        midpointStatus: midpoint_status,
        finalStatus: final_status
      }
    end

    def parse_cs_grading_status(cs_grading_status, is_law, is_summer)
      if unexpected_cs_status?(cs_grading_status, is_law)
        logger.warn "Unexpected CS Final Grading Status Received (Final: #{cs_grading_status[:finalStatus]}#{', Midpoint: ' + cs_grading_status[:midpointStatus] if cs_grading_status.key?(:midpointStatus)}) for Class #{self.class.name} feed, uid = #{@uid}"
        return {finalStatus: :noCsData, midpointStatus: :noCsData}
      end
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
      if !is_law && !is_summer
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

    def parse_cc_grading_status(cs_grading_status, is_law, is_midpoint, term_id)
      grading_period_status = get_grading_period_status(is_law, is_midpoint, term_id)
      grading_status_mapping[cs_grading_status][grading_period_status]
    end

    def parse_cc_grading_status_summer(section, cs_grading_status, term_id)
      grading_period_status = get_grading_period_status_summer(section, term_id)
      grading_status_mapping[cs_grading_status][grading_period_status]
    end

    def get_grading_period_status(is_law, is_midpoint, term_id)
      return :gradingPeriodNotSet unless valid_grading_period?(is_law, term_id)
      if is_law
        if term_id == '2168'
          return find_grading_period_status(grading_period.dates.law.fall_2016)
        elsif term_id == '2172'
          return find_grading_period_status(grading_period.dates.law.spring_2017)
        end
      elsif !is_law
        if term_id == '2168'
          return find_grading_period_status(grading_period.dates.general.fall_2016)
        elsif term_id == '2172'
          if is_midpoint
            return find_grading_period_status(grading_period.dates.general.spring_2017.midpoint)
          else
            return find_grading_period_status(grading_period.dates.general.spring_2017.final)
          end
        end
      end
    end

    def get_grading_period_status_summer(section, term_id)
      if term_id == '2175'
        grading_window = OpenStruct.new({
          start: section[:gradingPeriodStartDate],
          end: section[:gradingPeriodEndDate]
        })
      end
      find_grading_period_status(grading_window)
    end

    def find_grading_period_status(dates)
      current_date = Settings.terms.fake_now || DateTime.now
      return :beforeGradingPeriod if current_date < DateTime.parse(dates.start.to_s)
      return :afterGradingPeriod if current_date > DateTime.parse(dates.end.to_s)
      return :inGradingPeriod
    end

    def grading_period
      @grading_period ||= Settings.grading_period
    end

  end
end

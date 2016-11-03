module MyAcademics
  class Grading < UserSpecificModel

    def merge(data)
      teaching_semesters = data[:teachingSemesters]
      if teaching_semesters
        add_grading_to_semesters(teaching_semesters)
      end
    end

    def grading_link_mapping(grading_link)
      {
        noCsData: {
          beforeGradingPeriod: nil,
          inGradingPeriod:nil,
          afterGradingPeriod: nil,
          gradingPeriodNotSet: nil
        },
        GRD: {
          beforeGradingPeriod: nil,
          inGradingPeriod: grading_link,
          afterGradingPeriod: grading_link,
          gradingPeriodNotSet: grading_link
        },
        POST: {
          beforeGradingPeriod: grading_link,
          inGradingPeriod: grading_link,
          afterGradingPeriod: grading_link,
          gradingPeriodNotSet: grading_link
        }
      }
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
          gradingPeriodNotSet: :periodStarted,
        },
        POST: {
          beforeGradingPeriod:  :gradesSubmitted,
          inGradingPeriod:  :gradesSubmitted,
          afterGradingPeriod:  :gradesSubmitted,
          gradingPeriodNotSet:  :gradesSubmitted,
        }
      }
    end

    def add_grading_to_semesters(teaching_semesters)
      teaching_semesters.try(:each) do |semester|
        term_code = Berkeley::TermCodes.slug_to_edo_id(semester[:slug])
        add_assistance_link(semester)
        add_period_to_semester(semester, term_code)
        add_grading_to_classes(semester[:classes], term_code)
       end
    end

    def add_assistance_link(semester)
      semester.merge!(
        {
          gradingAssistanceLink:  Settings.grading_period.general.assistance_link,
          gradingAssistanceLinkLaw:  Settings.grading_period.law.assistance_link
        })
    end

    def add_period_to_semester(semester, term_code)
      # This is a temp fix for Fall 2016 hardcoded from settings
      if term_code == '2168' && valid_grading_period?
        semester.merge!(
          {
            gradingPeriodStart: role_grading_period.start.to_date.strftime("%b %d"),
            gradingPeriodEnd: role_grading_period.end.to_date.strftime("%b %d")
          })
      else
        semester.merge!(
          {
            gradingPeriodStart: nil,
            gradingPeriodEnd: nil
          })
      end
    end

    def add_grading_to_classes(semester_classes, term_code)
      semester_classes.try(:each) do |semester_class|
        add_grading_to_class(semester_class, term_code)
      end
    end

    def add_grading_to_class(semester_class, term_code)
      semester_class.try(:[],:sections).try(:each) do |section|
        ccn = section[:ccn]
        cs_grading_status = parse_cs_grading_status(get_cs_status(ccn, term_code))
        section.merge!(
          {
            csGradingStatus: section[:is_primary_section] ? cs_grading_status : nil,
            ccGradingStatus: section[:is_primary_section] ? parse_cc_grading_status(cs_grading_status): nil,
            gradingLink: section[:is_primary_section] ? get_grading_link(ccn, term_code, cs_grading_status) : nil
          })
      end
    end

    def get_grading_link(ccn, term_code, cc_grading_status)
      return nil unless ccn && term_code
      grading_link = AcademicsModule::fetch_link('UC_CX_SSS_GRADE_ROSTER', { STRM: term_code, CLASS_NBR: ccn })
      grading_period_status = get_grading_period_status
      mapping = grading_link_mapping(grading_link)
      mapping[cc_grading_status][grading_period_status]
    end

    def get_cs_status(ccn, term_code)
      cnn_status = nil
      if (grading_feed = CampusSolutions::Grading.new(user_id: @uid).get)
        grading_statuses = grading_feed[:feed].try(:[],:ucSrClassGrading).try(:[],:classGradingStatuses)
        cnn_status = find_ccn_grading_statuses(grading_statuses, ccn, term_code)
      end
      cnn_status
    end

    def find_ccn_grading_statuses(grading_statuses, ccn, term_code)
      return nil unless ccn && term_code && grading_statuses
      status_array  = grading_statuses.try(:[], :classGradingStatus)
      # if feed returned single status it will not be wrapped in array
      # need to wrap in array for code to iterate correctly
      status_array =  status_array.blank? || status_array.kind_of?(Array) ? status_array : [] << status_array
      rosters = status_array.try(:find) do |grading_status|
        grading_status[:strm] == term_code && grading_status[:classNbr] == ccn
      end.try(:[],:roster)
      find_fin_grade_in_rosters(rosters)
    end

    def find_fin_grade_in_rosters(rosters)
      # if feed returned single roster it will not be wrapped in array
      # need to wrap in array for code to iterate correctly
      roster_array = rosters.blank? || rosters.kind_of?(Array) ? rosters : [] << rosters
      roster_array.try(:find) do |r|
        r[:gradeRosterTypeCode].present? && r[:gradeRosterTypeCode] == 'FIN'
      end.try(:[],:gradingStatusCode)
    end

    def parse_cs_grading_status(cs_grading_status)
      return :noCsData if unexpected_cs_status?(cs_grading_status)
      case cs_grading_status
        when 'GRD', 'RDY', 'APPR'
          :GRD
        when 'POST'
          :POST
        else
          :noCsData
      end
    end

    def parse_cc_grading_status(cs_grading_status)
      grading_period_status = get_grading_period_status
      grading_status_mapping[cs_grading_status][grading_period_status]
    end

    def unexpected_cs_status?(cs_grading_status)
      return false if !!%w{GRD RDY APPR POST}.find { |s| s == cs_grading_status } || cs_grading_status.blank?
      logger.debug "Unexpected CS Grading Status Received #{cs_grading_status} for Class #{self.class.name} feed, uid = #{@uid}"
      true
    end

    def get_grading_period_status
      return :gradingPeriodNotSet unless valid_grading_period?
      return :beforeGradingPeriod if DateTime.now < DateTime.parse(role_grading_period.start.to_s)
      return :afterGradingPeriod if DateTime.now > DateTime.parse(role_grading_period.end.to_s)
      :inGradingPeriod
    end

    def valid_grading_period?
      # Use class level var to reduce noise in log on invalid grading period
      return @valid_grading_period unless @valid_grading_period.nil?
      @valid_grading_period = check_grading_period?
      @valid_grading_period
    end

    def check_grading_period?
      return false if period_dates_not_set?
      return false if period_start_bad_format?
      return false if period_end_bad_format?
      return false if period_dates_bad_order?
      true
    end

    def period_dates_not_set?
      role_grading_period.start.blank? || role_grading_period.end.blank?
    end

    def period_start_bad_format?
      begin
        DateTime.parse(role_grading_period.start.to_s)
      rescue
        logger.error "Bad Format For Grading Period Start in Settings for Class #{self.class.name} feed, uid = #{@uid}"
        return true
      end
      false
    end

    def period_end_bad_format?
      begin
        DateTime.parse(role_grading_period.end.to_s)
      rescue
        logger.error "Bad Format For Grading Period End in Settings for Class #{self.class.name} feed, uid = #{@uid}"
        return true
      end
      false
    end

    def period_dates_bad_order?
      if DateTime.parse(role_grading_period.start.to_s) >= DateTime.parse(role_grading_period.end.to_s)
        logger.error "Grading Period Start After End in Settings for Class #{self.class.name} feed, uid = #{@uid}"
        return true
      end
      false
    end

    def role_grading_period
      return Settings.grading_period.law if authentication_state.policy.law_student?
      Settings.grading_period.general
    end

  end
end

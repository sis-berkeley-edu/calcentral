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
        },
        RDY: {
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
          beforeGradingPeriod:  :gradesPosted,
          inGradingPeriod:  :gradesPosted,
          afterGradingPeriod:  :gradesPosted,
          gradingPeriodNotSet:  :gradesPosted,
        },
        RDY: {
          beforeGradingPeriod:  :gradesApproved,
          inGradingPeriod:  :gradesApproved,
          afterGradingPeriod:  :gradesApproved,
          gradingPeriodNotSet:  :gradesApproved,
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
      # This is a temp fix for Fall 2016 hardcoded from settings
      if term_code == '2168' && valid_grading_period?(false)
        semester.merge!(
          {
            gradingAssistanceLink:  Settings.grading_period.general.assistance_link,
            gradingPeriodStart: role_grading_period(false).start.to_date.strftime('%b %d'),
            gradingPeriodEnd:  format_period_end(role_grading_period(false).end.to_date)
          })
      else
        semester.merge!(
          {
            gradingAssistanceLink:  Settings.grading_period.general.assistance_link,
            gradingPeriodStart: nil,
            gradingPeriodEnd: nil
          })
      end
    end

    def add_grading_header_law(semester, term_code)
      # This is a temp fix for Fall 2016 hardcoded from settings
      if term_code == '2168' && valid_grading_period?(true)
        semester.merge!(
          {
            gradingAssistanceLinkLaw:  Settings.grading_period.law.assistance_link,
            gradingPeriodStartLaw: role_grading_period(true).start.to_date.strftime('%b %d'),
            gradingPeriodEndLaw: format_period_end(role_grading_period(true).end.to_date)
          })
      else
        semester.merge!(
          {
            gradingAssistanceLinkLaw:  Settings.grading_period.law.assistance_link,
            gradingPeriodStartLaw: nil,
            gradingPeriodEndLaw: nil
          })
      end
    end

    def format_period_end(end_date)
      return end_date.strftime('%b %d') if DateTime.now.year == end_date.year
      end_date.strftime('%b %d, %Y')
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
        cs_grading_status = parse_cs_grading_status(get_cs_status(ccn, term_code))
        section.merge!(
          {
            csGradingStatus: section[:is_primary_section] ? cs_grading_status : nil,
            ccGradingStatus: section[:is_primary_section] && has_grading_access ? parse_cc_grading_status(cs_grading_status, is_law): nil,
            gradingLink: section[:is_primary_section] && has_grading_access ? get_grading_link(ccn, term_code, cs_grading_status, is_law) : nil
          })
      end
    end

    def has_grading_access?(section)
      !!section[:instructors].try(:find) do |instructor|
        instructor[:uid] == @uid && instructor[:ccGradingAccess] != :noGradeAccess
      end
    end

    def get_grading_link(ccn, term_code, cc_grading_status, is_law)
      return nil unless ccn && term_code
      grading_link = AcademicsModule::fetch_link('UC_CX_SSS_GRADE_ROSTER', { STRM: term_code, CLASS_NBR: ccn, INSTITUTION: 'UCB01' })
      grading_period_status = get_grading_period_status(is_law)
      mapping = grading_link_mapping(grading_link)
      mapping[cc_grading_status][grading_period_status]
    end

    def get_cs_status(ccn, term_code)
      cnn_status = nil
      if (grading_feed = get_grading_data)
        grading_statuses = grading_feed[:feed].try(:[],:ucSrClassGrading).try(:[],:classGradingStatuses)
        cnn_status = find_ccn_grading_statuses(grading_statuses, ccn, term_code)
      end
      cnn_status
    end

    def get_grading_data
      @grading_feed ||= CampusSolutions::Grading.new(user_id: @uid).get
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
        when 'GRD'
          :GRD
        when 'POST'
          :POST
        when 'RDY'
          :RDY
        else
          :noCsData
      end
    end

    def parse_cc_grading_status(cs_grading_status, is_law)
      grading_period_status = get_grading_period_status(is_law)
      grading_status_mapping[cs_grading_status][grading_period_status]
    end

    def unexpected_cs_status?(cs_grading_status)
      return false if !!%w{GRD RDY APPR POST}.find { |s| s == cs_grading_status } || cs_grading_status.blank?
      logger.debug "Unexpected CS Grading Status Received #{cs_grading_status} for Class #{self.class.name} feed, uid = #{@uid}"
      true
    end

    def get_grading_period_status(is_law)
      return :gradingPeriodNotSet unless valid_grading_period?(is_law)
      return :beforeGradingPeriod if DateTime.now < DateTime.parse(role_grading_period(is_law).start.to_s)
      return :afterGradingPeriod if DateTime.now > DateTime.parse(role_grading_period(is_law).end.to_s)
      :inGradingPeriod
    end

    def valid_grading_period?(is_law)
      # Use class level var to reduce noise in log on invalid grading period
      return @valid_grading_period if !is_law  && @valid_grading_period.present?
      return @valid_grading_period_law if is_law && @valid_grading_period_law.present?
      @valid_grading_period = check_grading_period?(is_law) unless is_law
      @valid_grading_period_law = check_grading_period?(is_law) if is_law
      is_law ? @valid_grading_period_law : @valid_grading_period
    end

    def check_grading_period?(is_law)
      return false if period_dates_not_set?(is_law)
      return false if period_start_bad_format?(is_law)
      return false if period_end_bad_format?(is_law)
      return false if period_dates_bad_order?(is_law)
      true
    end

    def period_dates_not_set?(is_law)
      role_grading_period(is_law).start.blank? || role_grading_period(is_law).end.blank?
    end

    def period_start_bad_format?(is_law)
      begin
        DateTime.parse(role_grading_period(is_law).start.to_s)
      rescue
        logger.error "Bad Format For Grading Period Start in Settings for Class #{self.class.name} feed, uid = #{@uid}"
        return true
      end
      false
    end

    def period_end_bad_format?(is_law)
      begin
        DateTime.parse(role_grading_period(is_law).end.to_s)
      rescue
        logger.error "Bad Format For Grading Period End in Settings for Class #{self.class.name} feed, uid = #{@uid}"
        return true
      end
      false
    end

    def period_dates_bad_order?(is_law)
      if DateTime.parse(role_grading_period(is_law).start.to_s) >= DateTime.parse(role_grading_period(is_law).end.to_s)
        logger.error "Grading Period Start After End in Settings for Class #{self.class.name} feed, uid = #{@uid}"
        return true
      end
      false
    end

    def role_grading_period(is_law)
      return Settings.grading_period.law if is_law
      Settings.grading_period.general
    end

  end
end

module MyAcademics
  module Grading
    class Applicator < UserSpecificModel
      include Helpers
      include LinkFetcher

      def merge(data)
        teaching_semesters = data[:teachingSemesters]
        if teaching_semesters
          add_grading_to_semesters(teaching_semesters)
        end
      end

      def add_grading_to_semesters(teaching_semesters)
        teaching_semesters.try(:each) do |semester|
          term_id = Berkeley::TermCodes.slug_to_edo_id(semester[:slug])
          add_grading_information_links(semester)

          add_legacy_term_grading_to_classes(semester[:classes], term_id) if legacy_grading_term_type(term_id) == :legacy_term
          add_legacy_class_grading_to_classes(semester[:classes], term_id) if legacy_grading_term_type(term_id) == :legacy_class

          if legacy_grading_term_type(term_id) == :cs
            add_grading_dates(semester, term_id)
            add_grading_to_classes(semester[:classes], term_id)
          end
        end
      end

      def add_grading_information_links(semester)
        if has_non_law_classes?(semester[:classes])
          # A termCode of 'C' denotes a summer term. Every non-law term has midpoint grading, except summer.
          if is_summer_semester? semester
            semester.merge!({
              gradingAssistanceLink: grading_info_links[:general].try(:[], :url)
            })
          else
            semester.merge!({
              gradingAssistanceLinkMidpoint: grading_info_links[:midterm].try(:[], :url),
              gradingAssistanceLink: grading_info_links[:general].try(:[], :url)
            })
          end
        end
        if has_career_class?('LAW', semester[:classes])
          semester.merge!({
            gradingAssistanceLinkLaw: grading_info_links[:law].try(:[], :url)
          })
        end
      end

      def add_grading_dates(semester, term_id)
        if MyAcademics::Grading::Session.grading_term_present?(term_id)
          if is_summer_semester? semester
            add_grading_dates_to_summer_classes(semester[:classes], term_id)
          else
            add_grading_dates_general(semester, term_id) if has_non_law_classes?(semester[:classes])
            add_grading_dates_law(semester, term_id) if has_career_class?('LAW', semester[:classes])
          end
        end
      end

      def add_grading_dates_general(semester, term_id)
        has_ugrd_classes = has_career_class?('UGRD', semester[:classes])
        has_grad_classes = has_career_class?('GRAD', semester[:classes])

        ugrd_session = MyAcademics::Grading::Session.get_session(term_id, 'UGRD')
        grad_session = MyAcademics::Grading::Session.get_session(term_id, 'GRAD')

        applicable_midterm_periods = Array.new.tap do |array|
          if ugrd_session.midterm_period == grad_session.midterm_period
            array << ugrd_session.midterm_period
          else
            array << ugrd_session.midterm_period if has_ugrd_classes
            array << grad_session.midterm_period if has_grad_classes
          end
        end

        applicable_final_periods = Array.new.tap do |array|
          if ugrd_session.final_period == grad_session.final_period
            array << ugrd_session.final_period
          else
            array << ugrd_session.final_period if has_ugrd_classes
            array << grad_session.final_period if has_grad_classes
          end
        end

        if applicable_midterm_periods.length == 1
          semester.merge!({
            gradingPeriodStartMidpoint: applicable_midterm_periods.first.formatted_start_date,
            gradingPeriodEndMidpoint: applicable_midterm_periods.first.formatted_due_date,
          })
        elsif applicable_midterm_periods.length > 1
          semester.merge!({
            gradingPeriodStartMidpoint: ugrd_session.midterm_period.formatted_start_date,
            gradingPeriodEndMidpoint: ugrd_session.midterm_period.formatted_due_date,
            gradingPeriodStartMidpointGrad: grad_session.midterm_period.formatted_start_date,
            gradingPeriodEndMidpointGrad: grad_session.midterm_period.formatted_due_date,
          })
        end

        if applicable_final_periods.length == 1
          semester.merge!({
            gradingPeriodStartFinal: applicable_final_periods.first.formatted_start_date,
            gradingPeriodEndFinal: applicable_final_periods.first.formatted_due_date,
          })
        elsif applicable_final_periods.length > 1
          semester.merge!({
            gradingPeriodStartFinal: ugrd_session.final_period.formatted_start_date,
            gradingPeriodEndFinal: ugrd_session.final_period.formatted_due_date,
            gradingPeriodStartFinalGrad: grad_session.final_period.formatted_start_date,
            gradingPeriodEndFinalGrad: grad_session.final_period.formatted_due_date,
          })
        end
      end

      def has_career_class?(career_code, semester_classes)
        !!semester_classes.try(:find) do |semester_class|
          semester_class.try(:[], :courseCareerCode) == career_code
        end
      end

      def add_grading_dates_law(semester, term_id)
        grading_session = MyAcademics::Grading::Session.get_session(term_id, 'LAW')
        semester.merge!(
          {
            gradingPeriodStartLaw: grading_session.try(:final_period).try(:formatted_start_date),
            gradingPeriodEndLaw: grading_session..try(:final_period).try(:formatted_due_date)
          }
        )
      end

      def add_grading_dates_to_summer_classes(semester_classes, term_id)
        semester_classes.try(:each) do |semester_class|
          semester_class.try(:[], :sections).try(:each) do |section|
            if is_primary_section? section
              add_grading_dates_to_summer_section(semester_class, section, term_id)
            end
          end
        end
      end

      def add_grading_dates_to_summer_section(semester_class, section, term_id)
        if session_id = section.try(:[], :session_id)
          acad_career_code = semester_class[:courseCareerCode]
          if acad_career_code == 'LAW'
            mapped_session_id = summer_law_session_mapping[session_id].to_s
          else
            mapped_session_id = :session_id
          end
          grading_session = MyAcademics::Grading::Session.get_session(term_id, 'LAW', mapped_session_id)
          if (grading_session)
            begin_date = grading_session.final_period.start_date
            end_date = grading_session.final_period.due_date
            section.merge!({
              gradingPeriodStartDate: begin_date,
              gradingPeriodEndDate: end_date,
              gradingPeriodEndDateFormatted: format_period_end_summer(end_date).to_s
            })
          else
            logger.warn "No grading periods found for term: #{term_id}, career: #{acad_career_code}"
          end
        else
          logger.error "No session ID found for section #{section[:ccn]}, course ID #{semester_class[:course_id]}"
        end
      end

      def add_grading_to_classes(semester_classes, term_id)
        semester_classes.try(:each) do |semester_class|
          add_grading_to_class(semester_class, term_id)
        end
      end

      def add_legacy_term_grading_to_classes(semester_classes, term_id)
        grading_link = fetch_link('UC_CX_TERM_GRD_LEGACY', { TERM_ID: term_id })
        semester_classes.try(:each) do |semester_class|
          semester_class.try(:[],:sections).try(:each) do |section|
            if is_primary_section? section
              has_grade_access = has_grading_access?(section)
              section.merge!(
                {
                  csGradingStatus: nil,
                  ccGradingStatus: has_grade_access ? :gradesPosted : nil,
                  gradingLink: has_grade_access ? grading_link : nil
                }
              )
            end
          end
        end
      end

      def add_legacy_class_grading_to_classes(semester_classes, term_id)
        semester_classes.try(:each) do |semester_class|
          semester_class.try(:[],:sections).try(:each) do |section|
            if is_primary_section? section
              ccn = section[:ccn]
              has_grade_access = has_grading_access?(section)
              grading_link = fetch_link('UC_CX_CRS_GRD_LEGACY', { TERM_ID: term_id, CLASS_NBR: ccn })
              section.merge!(
                {
                  csGradingStatus: nil,
                  ccGradingStatus: has_grade_access ? :gradesPosted : nil,
                  gradingLink: has_grade_access ? grading_link : nil
                }
              )
            end
          end
        end
      end

      def add_grading_to_class(semester_class, term_id)
        is_law = is_law_class? semester_class
        is_summer = is_summer_term? term_id
        grading_type = is_law ? :law : :general
        acad_career_code = semester_class[:courseCareerCode]

        semester_class.try(:[],:sections).try(:each) do |section|
          # Only primary sections have grade rosters.
          if is_primary_section? section
            section_session_id = section.try(:[], :session_id)
            ccn = section[:ccn]
            has_grade_access = has_grading_access?(section)
            cs_roster_status = get_cs_status(ccn, is_law, term_id)
            cs_grading_status = parse_cs_grading_status(cs_roster_status, is_law, is_summer)
            if cs_grading_session_config?(term_id, acad_career_code, section_session_id)
              # Law and summer classes do not have midpoint grades.
              if is_law && !is_summer
                section.merge!(
                  {
                    csGradingStatus: cs_grading_status[:finalStatus],
                    ccGradingStatus: has_grade_access ? parse_cc_grading_status(cs_grading_status[:finalStatus], is_law, false, term_id) : nil
                  }
                )
              elsif is_summer
                section.merge!(
                  {
                    csGradingStatus: cs_grading_status[:finalStatus],
                    ccGradingStatus: has_grade_access ? parse_cc_grading_status(cs_grading_status[:finalStatus], is_law, false, term_id, section) : nil
                  }
                )
              else
                section.merge!(
                  {
                    csMidpointGradingStatus: cs_grading_status[:midpointStatus],
                    ccMidpointGradingStatus: has_grade_access ? parse_cc_grading_status(cs_grading_status[:midpointStatus], is_law, true, term_id) : nil,
                    csGradingStatus: cs_grading_status[:finalStatus],
                    ccGradingStatus: has_grade_access ? parse_cc_grading_status(cs_grading_status[:finalStatus], is_law, false, term_id) : nil
                  }
                )
              end
            end
            # We want to include the link to the grading roster if it exists, without regard for status or whether it's an active grading term
            section.merge!(
              {
                gradingLink: has_grade_access ? get_grading_link(ccn, term_id, cs_grading_status) : nil
              }
            )
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
        status = nil
        if (grading_feed = get_grading_data)
          grading_statuses = grading_feed.try(:[],:feed).try(:[],:ucSrClassGrading).try(:[],:classGradingStatuses)
          status = find_ccn_grading_statuses(grading_statuses, ccn, is_law, term_id)
        end
        status
      end

      def get_grading_data
        @grading_feed ||= CampusSolutions::Grading.new(user_id: @uid).get
      end

      def find_ccn_grading_statuses(grading_statuses, ccn, is_law, term_id)
        return nil unless grading_statuses && ccn && term_id
        status_array  = grading_statuses.try(:[], :classGradingStatus)
        # if feed returned single status it will not be wrapped in array
        # need to wrap in array for code to iterate correctly
        status_array = status_array.blank? || status_array.kind_of?(Array) ? status_array : [] << status_array
        rosters = status_array.try(:find) do |grading_status|
          grading_status[:strm] == term_id && grading_status[:classNbr] == ccn
        end.try(:[],:roster)
        is_summer = is_summer_term? term_id
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
          logger.warn "Unexpected CS Final Grading Status Received (Final: #{cs_grading_status.try(:[], :finalStatus)}, Midpoint: #{cs_grading_status.try(:[], :midpointStatus)}) for uid #{@uid}"
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

      def parse_cc_grading_status(cs_grading_status, is_law, is_midpoint, term_id, section = nil)
        acad_career_code = is_law ? 'LAW' : 'UGRD'
        session_id = section.try(:[], :session_id) || '1'
        grading_session = MyAcademics::Grading::Session.get_session(term_id, acad_career_code)

        if cs_grading_session_config?(term_id, acad_career_code, session_id)
          if section.present?
            # summer has no midterm
            summer_grading_window = {
              final_begin_date: section[:gradingPeriodStartDate],
              final_end_date: section[:gradingPeriodEndDate]
            }
            grading_status = find_grading_period_status(summer_grading_window, false)
          else
            grading_session = MyAcademics::Grading::Session.get_session(term_id, acad_career_code)
            grading_status = find_grading_period_status(grading_session, is_midpoint)
          end
        else
          grading_status = :gradingPeriodNotSet
        end
        grading_status_mapping[cs_grading_status.to_sym][grading_status]
      end

      def find_grading_period_status(grading_session, is_midpoint)
        if is_midpoint
          begin_date = grading_session.midterm_period.try(:start_date).try(:in_time_zone).try(:to_datetime)
          end_date = grading_session.midterm_period.try(:due_date).try(:end_of_day).try(:to_datetime)
        else
          begin_date = grading_session.final_period.try(:start_date).try(:in_time_zone).try(:to_datetime)
          end_date = grading_session.final_period.try(:due_date).try(:end_of_day).try(:to_datetime)
        end
        current_date = Settings.terms.fake_now || DateTime.now
        return :gradingPeriodNotSet if begin_date.blank? || end_date.blank?
        return :beforeGradingPeriod if current_date < DateTime.parse(begin_date.to_s)
        return :afterGradingPeriod if current_date > DateTime.parse(end_date.to_s)
        return :inGradingPeriod
      end

      def grading_info_links
        @grading_info_links ||= MyAcademics::Grading::InfoLinks.fetch
      end

      # def cs_grading_term_present?(term_id)
      #   edo_grading_sessions.keys.include? term_id
      # end

      def cs_grading_session_config?(term_id, acad_career_code, session_id)
        !!MyAcademics::Grading::Session.get_session(term_id, acad_career_code, session_id)
      end
    end
  end
end

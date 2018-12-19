module MyAcademics
  module Grading
    module Helpers
      extend self

      LAW_2178 = "Law Fall 2017"
      LAW_2182 = "Law Spring 2018"
      GEN_MID_2178 = "General Midpoint Fall 2017"
      GEN_FIN_2178 = "General Final Fall 2017"
      GEN_MID_2182 = "General Midpoint Spring 2018"
      GEN_FIN_2182 = "General Final Spring 2018"

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

      def is_law_class?(semester_class)
        semester_class.try(:[], :courseCareerCode) == 'LAW'
      end

      def is_summer_term?(term_id)
        Berkeley::TermCodes.edo_id_is_summer?(term_id)
      end

      def is_summer_semester?(semester)
        semester[:termCode] == 'C'
      end

      def has_non_law_classes?(semester_classes)
        !!semester_classes.try(:find) do |semester_class|
          !is_law_class?(semester_class)
        end
      end

      def is_primary_section?(section)
        !!section.try(:[], :is_primary_section)
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

      def format_period_end_summer(end_date)
        return end_date.to_date.strftime('%m/%d') if DateTime.now.year == end_date.to_date.year
        end_date.to_date.strftime('%m/%d/%Y')
      end

      def legacy_grading_term_type(term_code)
        term_code_int = term_code.to_i
        return :none if term_code_int < 2012
        return :legacy_term if term_code_int >= 2012 && term_code_int <= 2072
        return :legacy_class if term_code_int >= 2075 && term_code_int <= 2165
        return :cs if term_code_int > 2165
      end
    end
  end
end

module User
  module Academics
    module Status
      class CancellationForNonPayment < Base
        def message
          return MSG_NONE if summer?
          return MSG_NONE unless undergraduate?
          return MSG_NONE unless tuition_calculated?
          return MSG_NONE if registered?
  
          if cnp_exception?
            MSG_CNP_EXCEPTION
          else
            MSG_SUBJECT_TO_CANCELLATION
          end
        end
  
        def severity
          if message == MSG_SUBJECT_TO_CANCELLATION
            if past_financial_disbursement?
              SEVERITY_WARNING
            else
              SEVERITY_NOTICE
            end
          elsif message == MSG_CNP_EXCEPTION
            SEVERITY_NORMAL
          else
            SEVERITY_NONE
          end
        end

        def detailed_message_html
          case severity
          when SEVERITY_NORMAL
            cnp_exception_service_indicator_message
          when SEVERITY_NOTICE
            message_catalog(:status_cnp_exception_before_disbursement)
          when SEVERITY_WARNING
            message_catalog(:status_cnp_exception_after_disbursement)
          end
        end

        def in_popover?
          [SEVERITY_NOTICE, SEVERITY_WARNING].include?(severity)
        end

        def badge_count
          [SEVERITY_WARNING].include?(severity) ? 1 : 0
        end
      end
    end
  end
end

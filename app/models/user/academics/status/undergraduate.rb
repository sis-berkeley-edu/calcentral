module User
  module Academics
    module Status
      class Undergraduate < Base
        def message
          return MSG_NONE if summer?
          return MSG_NONE unless tuition_calculated?
          return MSG_NOT_ENROLLED unless enrolled?
          return MSG_OFFICIALLY_REGISTERED if registered?
          MSG_NOT_OFFICIALLY_REGISTERED
        end

        def severity
          case message
          when MSG_OFFICIALLY_REGISTERED
            return SEVERITY_NORMAL
          when MSG_NOT_ENROLLED, MSG_NOT_OFFICIALLY_REGISTERED
            return SEVERITY_WARNING
          end
        end

        def detailed_message_html
          case message
          when MSG_OFFICIALLY_REGISTERED
             registration_service_indicator_message
          when MSG_NOT_ENROLLED
            '<p>You are not enrolled in any classes for this term.</p>'
          when MSG_NOT_OFFICIALLY_REGISTERED
            message_catalog(:status_not_officially_registered)
          end
        end
      end
    end
  end
end

module User
  module Academics
    module Status
      class Postgraduate < Base
        MSG_NOT_ENROLLED = 'Not enrolled'

        # Higher values are sorted earlier in a list
        RANKING = {
          MSG_NOT_ENROLLED   => 10,
          MSG_FULL_ACCESS    => 20,
          MSG_LIMITED_ACCESS => 30,
          MSG_FEES_UNPAID    => 40
        }

        # The postgraduate priority of Law and Graduate is only differentiated
        # in their subclasses by #enrolled? because all the other methods trace
        # back to StudentAttributes, but #enrolled? is determined by a
        # Registration Record which can be distinct between the two careers.
        #
        # The end result: the difference only matters to concurrent enrollment
        # students. In the generic case, this class can be used directly.
        def message
          return MSG_NOT_ENROLLED unless enrolled?
          return MSG_LIMITED_ACCESS if twenty_percent_cnp_exception?
          return MSG_FULL_ACCESS if registered?
          MSG_FEES_UNPAID
        end

        # Unknown message are ranked lower than anything known
        def message_rank
          RANKING.fetch(message) { 0 }
        end

        # The values are inverted to that the highest priority messages are
        # sorted first (the opposite of normal number sorting with Enumerable)
        def <=>(other)
          -self.message_rank <=> -other.message_rank
        end

        def severity
          case message
          when MSG_FULL_ACCESS
            return SEVERITY_NORMAL
          when MSG_FEES_UNPAID, MSG_LIMITED_ACCESS
            return SEVERITY_NOTICE
          when MSG_NOT_ENROLLED
            return SEVERITY_WARNING
          end
        end

        def detailed_message_html
          case message
          when MSG_NOT_ENROLLED
            message_catalog(:status_grad_or_law_not_enrolled)
          when MSG_FEES_UNPAID
            message_catalog(:status_grad_or_law_fees_unpaid)
          when MSG_LIMITED_ACCESS
            '<p>You may not have access to campus services due to a hold. Please address your holds to become entitled to campus services.</p>'
          end
        end

        def in_popover?
          [MSG_FEES_UNPAID, MSG_NOT_ENROLLED].include?(message)
        end

        def badge_count
          in_popover? ? 1 : 0
        end
      end
    end
  end
end

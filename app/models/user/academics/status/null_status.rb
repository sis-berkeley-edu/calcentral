module User
  module Academics
    module Status
      class NullStatus
        def as_json(options={})
          {
            message: message,
            severity: nil,
            detailedMessageHTML: nil,
            inPopover: in_popover?,
            badgeCount: badge_count
          }
        end

        def message
          nil
        end

        def in_popover?
          false
        end

        def badge_count
          0
        end
      end
    end
  end
end

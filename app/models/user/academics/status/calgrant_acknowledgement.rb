module User
  module Academics
    module Status
      class CalgrantAcknowledgement < Base
        def as_json(options = {})
          super(options).merge({
            link: link
          })
        end

        def message
          calgrant_acknowledgement.title
        end

        def severity
          calgrant_acknowledgement.complete? ? "normal" : "warning"
        end

        def detailed_message_html
          calgrant_acknowledgement.detailed_message_html
        end

        def in_popover?
          false
        end

        def badge_count
          0
        end

        def link
          calgrant_acknowledgement.link unless calgrant_acknowledgement.complete?
        end
      end
    end
  end
end

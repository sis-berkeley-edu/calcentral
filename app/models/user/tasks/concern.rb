module User
  module Tasks
    module Concern
      extend ActiveSupport::Concern

      included do
        def agreements
          @agreements ||= AgreementsFeed.new(uid)
        end

        def checklist_items
          @checklist_items ||= ChecklistFeed.new(uid)
        end

        def web_messages
          @web_messages ||= WebMessagesFeed.new(uid)
        end

        def completed_agreements
          @completed_agreements ||= CompletedAgreements.new(self)
        end

        def incomplete_agreements
          @incomplete_agreements ||= IncompleteAgreements.new(self)
        end

        def completed_checklist_items
          @completed_checklist_items ||= CompletedChecklistItems.new(self)
        end

        def incomplete_checklist_items
          @incomplete_checklist_items ||= IncompleteChecklistItems.new(self)
        end

        def notifications
          @notifications ||= Notifications.new(self)
        end

        def pending_web_messages
          @pending_web_messages ||= PendingWebMessages.new(self)
        end

        def has_canvas_access?
          @has_canvas_access ||= Canvas::Proxy.access_granted?(uid)
        end

        def has_google_apps_access?
          @has_google_apps_access || GoogleApps::Proxy.access_granted?(uid)
        end
      end
    end
  end
end

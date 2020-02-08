# require 'active_support/concern'

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

        def has_google_apps_access?
          @has_google_apps_access || GoogleApps::Proxy.access_granted?(uid)
        end
      end
    end
  end
end

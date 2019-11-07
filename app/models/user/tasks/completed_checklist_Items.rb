module User
  module Tasks
    class CompletedChecklistItems < ::User::Owned
      def as_json(options={})
        all
      end

      def all
        @all ||= complete_data.map do |item|
          CompletedChecklistItem.new(item)
        end
      end

      private

      def complete_data
        @complete_data ||= User::Tasks::Queries.completed_checklist_items(user.uid) || []
      end
    end
  end
end

module User
  module Tasks
    class IncompleteChecklistItems < ::User::Owned
      def as_json(options={})
        all
      end

      def all
        @all ||= data.map do |item|
          IncompleteChecklistItem.new(item)
        end
      end

      private

      def data
        @data ||= User::Tasks::Queries.incomplete_checklist_items(user.uid) || []
      end
    end
  end
end

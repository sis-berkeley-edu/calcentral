module User
  module Tasks
    class IncompleteChecklistItems < ::User::Owned
      attr_writer :data_source

      def as_json(options={})
        all
      end

      def all
        @all ||= data.map do |item|
          IncompleteChecklistItem.new(item)
        end.reject do |item|
          item.ignored?
        end
      end

      private

      def data
        @data ||= data_source.incomplete_checklist_items(user.uid) || []
      end

      def data_source
        @data_source ||= User::Tasks::Queries
      end
    end
  end
end

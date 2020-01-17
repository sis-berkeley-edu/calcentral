module User
  module Tasks
    class CompletedChecklistItem < ChecklistItem
      attr_accessor :checklist_code,
        :sequence_number,
        :checklist_sequence,
        :item_code,
        :admin_function,
        :status_code,
        :status_date,
        :title,
        :description,
        :due_date,
        :responsible_unit,
        :responsible_email,
        :aid_year,
        :aid_year_description,
        :item_status_xlt

      def initialize(attrs)
        attrs.each do |key, value|
          send("#{key}=", value) if respond_to?("#{key}=")
        end
      end

      def display_category
        DISPLAY_CATEGORIES.fetch(admin_function) { 'student' }
      end

      def as_json(options={})
        {
          aidYear: aid_year,
          aidYearName: aid_year_name,
          aidYearDescription: aid_year_description,
          completedDate: completed_on,
          checklistCode: checklist_code,
          checklistSequence: checklist_sequence,
          description: description,
          displayCategory: display_category,
          dueDate: due_on,
          itemCode: item_code,
          responsibleUnit: responsible_unit,
          responsibleEmail: responsible_email,
          sequenceNumber: sequence_number,
          title: title,
          status: status,
        }
      end

      def status
        item_status_xlt
      end

      def completed_on
        status_date&.to_date
      end

      def due_on
        due_date&.to_date
      end

      def action_text
      end

      def action_url
      end

      def aid_year_name
        aid_year_description&.delete('Aid Year ')
      end
    end
  end
end


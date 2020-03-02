module User
  module Tasks
    class CompletedChecklistItem < ChecklistItem
      attr_accessor :sequence_number,
        :checklist_sequence,
        :item_code,
        :title,
        :description,
        :department_name,
        :organization_name,
        :responsible_email,
        :item_status_xlt

      def as_json(options={})
        {
          aidYear: aid_year,
          aidYearName: aid_year_name,
          aidYearDescription: aid_year_description,
          completedDate: status_on,
          checklistCode: checklist_code,
          checklistSequence: checklist_sequence,
          departmentName: department_name,
          description: description,
          displayCategory: display_category,
          dueDate: due_on,
          itemCode: item_code,
          organizationName: organization_name,
          sequenceNumber: sequence_number,
          title: title,
          status: status,
        }
      end

      def status
        item_status_xlt
      end
    end
  end
end


module User
  module Tasks
    class IncompleteAgreement
      include ActiveModel::Model

      attr_accessor :admin_function,
        :aid_year,
        :aid_year_description,
        :assigned_date,
        :department_name,
        :description,
        :expires_on,
        :title,
        :transaction_id

      def as_json(options={})
        {
          aidYear: aid_year,
          aidYearName: aid_year_name,
          aidYearDescription: aid_year_description,
          assignedDate: assigned_date,
          departmentName: department_name,
          description: description,
          displayCategory: display_category,
          dueDate: due_date,
          isIncomplete: true,
          status: 'Assigned',
          title: title,
          type: 'IncompleteAgreement',
          url: url
        }
      end

      def aid_year_name
        "#{aid_year.to_i - 1}-#{aid_year}" if aid_year
      end

      def assigned_on
        assigned_date&.to_date
      end

      def due_date
        expires_on&.to_date unless display_category == "financialAid"
      end

      def url
        return if transaction_id.blank?

        @url ||= LinkFetcher.fetch_link('UC_CC_WEBMSG_AGRMNT', {
          CCI_COMM_TRANS_ID: transaction_id
        })
      end

      def display_category
        @display_category ||= ChecklistItem::DISPLAY_CATEGORIES.fetch(admin_function) { 'student' }
      end
    end
  end
end

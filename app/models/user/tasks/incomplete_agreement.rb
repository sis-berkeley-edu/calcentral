module User
  module Tasks
    class IncompleteAgreement < Agreement
      attr_accessor :aid_year,
        :aid_year_description,
        :assigned_date,
        :department_name,
        :description,
        :expires_on,
        :title,
        :transaction_id

      def as_json(options={})
        super.merge({
          aidYear: aid_year,
          aidYearName: aid_year_name,
          aidYearDescription: aid_year_description,
          assignedDate: assigned_date,
          departmentName: department_name,
          description: description,
          dueDate: due_date,
          isIncomplete: true,
          status: 'Assigned',
          statusDate: assigned_on,
          title: title,
          type: 'IncompleteAgreement',
          url: url
        })
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
    end
  end
end

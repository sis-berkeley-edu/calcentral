module User
  module Tasks
    class IncompleteChecklistItem < ChecklistItem
      include ActiveModel::Model

      attr_accessor :action_url,
        :action_text,
        :admin_function,
        :department_name,
        :due_date,
        :title,
        :item_code,
        :aid_year,
        :aid_year_description,
        :assigned_date,
        :status_code,
        :description,
        :has_upload_button,
        :upload_url_id

      def as_json(options={})
        {
          actionUrl: action_url_or_nil,
          aidYear: aid_year,
          aidYearName: aid_year_name,
          assignedDate: assigned_on,
          description: description,
          departmentName: department_name,
          displayCategory: display_category,
          dueDate: due_on,
          hasUpload: has_upload?,
          isBeingProcessed: being_processed?,
          isIncomplete: incomplete?,
          status: status,
          title: title,
          uploadUrl: upload_url
        }
      end

      def aid_year_name
        "#{aid_year.to_i - 1}-#{aid_year}" if aid_year
      end

      def due_on
        due_date&.to_date
      end

      def assigned_on
        assigned_date&.to_date
      end

      # Sometimes the action_url is " " (single space string), other times ""
      # (completely empty). In either case, we make in nil
      def action_url_or_nil
        action_url unless action_url.blank?
      end

      def has_upload?
        has_upload_button == "Y"
      end

      def upload_url
        return if upload_url_id.blank?
        @upload_url ||= LinkFetcher.fetch_link(upload_url_id)
      end

      def display_category
        return 'residency' if item_code[0, 2] == 'RR'
        DISPLAY_CATEGORIES.fetch(admin_function) { 'student' }
      end

      def being_processed?
        ['Processing', 'Received'].include?(status)
      end

      def completed?
        ['Completed', 'Waived'].include?(status)
      end

      def incomplete?
        ['Assigned', 'Incomplete'].include?(status)
      end
    end
  end
end

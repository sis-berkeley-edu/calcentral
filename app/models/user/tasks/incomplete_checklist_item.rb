module User
  module Tasks
    class IncompleteChecklistItem < ChecklistItem
      attr_accessor :action_url,
        :action_text,
        :department_name,
        :title,
        :item_code,
        :description,
        :has_upload_button,
        :upload_url_id,
        :organization_name,
        :sequence_id,
        :checklist_id,
        :checklist_item_code,
        :term_career_code,
        :term_id,
        :career,
        :admissions_application_number,
        :career_number,
        :student_career_code

      def as_json(options={})
        super.merge({
          actionUrl: action_url_or_nil,
          actionText: action_text,
          aidYear: aid_year,
          aidYearName: aid_year_name,
          assignedDate: status_on,
          description: description,
          departmentName: department_name,
          dueDate: due_on,
          hasUpload: has_upload?,
          isBeingProcessed: being_processed?,
          isIncomplete: incomplete?,
          isSir: sir?,
          status: status,
          statusDate: status_on,
          title: title,
          uploadUrl: upload_url,
          organizationName: organization_name,
        })
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
        @upload_url ||= LinkFetcher.fetch_link(upload_url_id, {
          ADMIN_FUNCTION: admin_function,
          SEQ_3C: sequence_id.to_s,
          CHECKLIST_SEQ: checklist_id.to_s,
          CHKLST_ITEM_CD: checklist_item_code,
          FIN_YEAR: aid_year,
          STRM_CAREER: term_career_code,
          STRM: term_id,
          ADM_APPL_NBR: admissions_application_number,
          ADMA_CAREER: career,
          STDNT_CAR_NBR: career_number.to_s,
          ACAD_CAREER: student_career_code,
        })
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

module User
  module Tasks
    class ChecklistItem
      attr_accessor :admin_function,
        :aid_year,
        :aid_year_description,
        :checklist_code,
        :due_date,
        :item_code,
        :status_code,
        :status_date

      def initialize(attrs={})
        attrs.each do |key, value|
          send("#{key}=", value) if respond_to?("#{key}=")
        end
      end

      def as_json(options={})
        {
          displayCategory: display_category,
          isFinancialAid: financial_aid?,
        }
      end

      IGNORED_STATUS_CODES = ['O', 'T', 'X']

      # SIR -> Statement of Intent to Register
      SIR_CHECKLIST_CODES = ["AUSIR", "AGSIR1", "AGHSIR", "AGPSIR", "ALSIR1"]

      STATUS_PROCESSING = 'A' # for "Active"
      STATUS_COMPLETE = 'C'
      STATUS_ASSIGNED = 'I' # for "Initiated"
      STATUS_NOTIFIED = 'N'
      STATUS_ORDERED = 'O'
      STATUS_RECEIVED = 'R'
      STATUS_RETURNED = 'T'
      STATUS_WAIVED = 'W'
      STATUS_CANCELLED = 'X'
      STATUS_INCOMPLETE = 'Z'

      STATUSES = {
        STATUS_PROCESSING => 'Processing',
        STATUS_COMPLETE => 'Completed',
        STATUS_ASSIGNED => 'Assigned',
        STATUS_NOTIFIED => 'Notified',
        STATUS_ORDERED => 'Ordered',
        STATUS_RECEIVED => 'Received',
        STATUS_RETURNED => 'Returned',
        STATUS_WAIVED => 'Waived',
        STATUS_CANCELLED => 'Cancelled',
        STATUS_INCOMPLETE => 'Incomplete',
      }

      def financial_aid?
        admin_function == 'FINA'
      end

      def status
        STATUSES[status_code]
      end

      def display_category
        @display_category ||= DisplayCategory.new(admin_function, item_code).to_s
      end

      def aid_year_name
        "#{aid_year.to_i - 1}-#{aid_year}" if aid_year
      end

      def due_on
        due_date&.to_date
      end

      def status_on
        status_date&.to_date
      end

      def sir?
        SIR_CHECKLIST_CODES.include? checklist_code
      end

      def ignored?
        IGNORED_STATUS_CODES.include? status_code
      end
    end
  end
end

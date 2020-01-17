module User
  module Tasks
    class ChecklistItem
      DISPLAY_CATEGORIES = {
        "ADMA" => "newStudent",
        "ADMP" => "admissions",
        "FINA" => "financialAid"
      }

      IGNORED_STATUS_CODES = ['O', 'T', 'X'];

      STATUSES = {
        'A' => 'Processing', # 'Active'
        'C' => 'Completed',
        'I' => 'Assigned', # 'Initiated
        'O' => 'Ordered',
        'R' => 'Received',
        'T' => 'Returned',
        'W' => 'Waived',
        'X' => 'Cancelled',
        'Z' => 'Incomplete'
      }

      def status
        STATUSES[status_code]
      end
    end
  end
end

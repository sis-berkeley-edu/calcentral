module User
  module Tasks
    class DisplayCategory
      attr_reader :admin_function, :item_code

      # TODO: Update the "financialAid" to "finances" in upcoming Tasks UI
      # refactor. financialAid isn't really accurrate and leads to situations
      # where #display_category => "financialAid" and #financial_aid? => false
      DISPLAY_CATEGORIES = {
        "ADMA" => "newStudent",
        "ADMP" => "admissions",
        "FINA" => "financialAid",
        "SFAC" => "financialAid",
        "BDGT" => "financialAid"
      }

      def initialize(admin_function, item_code=nil)
        @admin_function = admin_function
        @item_code = item_code
      end

      def to_s
        return 'residency' if item_code && item_code[0, 2] == 'RR'
        DISPLAY_CATEGORIES.fetch(admin_function) { 'student' }
      end
    end
  end
end

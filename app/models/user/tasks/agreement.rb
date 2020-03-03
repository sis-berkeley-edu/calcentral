module User
  module Tasks
    class Agreement
      attr_accessor :admin_function

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

      def display_category
        @display_category ||= DisplayCategory.new(admin_function).to_s
      end

      def financial_aid?
        admin_function == "FINA"
      end
    end
  end
end

module User
  module FinancialAid
    class Award
      include ActiveModel::Model

      attr_accessor :description
      attr_accessor :award_type
      attr_writer :value

      def as_json(options={})
        {
          description: description,
          value: value
        }
      end

      def value
        @value.to_f
      end

      def type
        award_type
      end
    end
  end
end

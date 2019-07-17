module User
  module Finances
    class Payment
      def initialize(data)
        @data = data
      end

      def as_json(options={})
        {
          description: @data['description'],
          amount_paid: @data['amount_paid'],
          posted_date: @data['posted_date']&.to_date,
          effective_date: @data['effective_date']&.to_date,
          raw: @data
        }
      end
    end
  end
end

module User
  module Finances
    class SequenceItem
      attr_accessor :data

      def initialize(data)
        @data = data
      end

      def as_json(options={})
        {
          id: @data['sequence_id'].to_i,
          amount: @data['sequence_amount'].to_f,
          posted: @data['sequence_posted'].to_date
        }
      end
    end
  end
end

module User
  module Finances
    class BillingItem
      attr_reader :id
      attr_reader :user

      def initialize(id, user)
        @id = id
        @user = user
      end

      def <<(sequence_data)
        sequence_items << ::User::Finances::SequenceItem.new(sequence_data)
      end

      def as_json(options={})
        json = {
          id: id,
          transaction_number: transaction_number,
          balance: data['balance'].to_f,
          description:  data['description'],
          amount: data['amount'].to_f,
          amount_due: data['amount_due'].to_f,
          due_date: due_date,
          adjustments: sequence_items,
          term_id: term_id,
          type: type,
          type_code: data['type_code'],
          posted_on: posted_on,
          updated_on: updated_on,
        }

        return json unless options[:include_payments]

        json.merge({
          payments: payments
        })
      end

      def transaction_number
        data['transaction_number'].present? ? data['transaction_number'] : nil
      end

      def term_id
        data['term_id'].present? ? data['term_id'] : nil
      end

      def due_date
        data['due_date']&.to_date
      end

      def posted_on
        data['sequence_posted']&.to_date
      end

      def updated_on
        data['updated_on']&.to_date
      end

      def type
        types.fetch(data['type_code']) { 'Transaction' }
      end

      def payments
        @payments ||= Payments.new(user, id).all
      end

      private

      def sequence_items
        @sequence_items ||= []
      end

      def data
        sequence_items.first.data
      end

      def types
        {
          'C' => 'Charge',
          'D' => 'Deposit',
          'F' => 'Financial Aid',
          'P' => 'Payment',
          'R' => 'Refund',
          'W' => 'Adjustment',
          'X' => 'Charge' # X is for "Write-Off", but we want to display
                          # "Charge" in the front end
        }
      end
    end
  end
end

module User
  module Finances
    class BillingSummary
      attr_accessor :user

      delegate :billing_items, to: :user

      def initialize(user)
        @user = user
      end

      def as_csv
        CSV.generate do |csv|
          csv << [disclaimer];
          csv << [];
          csv << ['Due Now', due_now, '',
                  'Overdue', overdue]
          csv << ['Not Yet Due', not_yet_due]
          csv << ['Total Unpaid Balance:',  balance]

          csv << []; csv << [];

          csv << [
            "Date Posted",
            "Description",
            "Type",
            "Status",
            "Due Amount",
            "Due Date",
            "Term",
            "Transaction Number",
            "Transaction Amount"
          ]

          billing_items.reverse.each do |billing_item|
            csv << [
              billing_item.posted_on,
              billing_item.description,
              billing_item.type,
              billing_item.status,
              billing_item.amount_due.to_f < 0.0 ? 0: billing_item.amount_due,
              billing_item.due_date,
              billing_item.term_name,
              billing_item.transaction_number,
              billing_item.amount
            ]
          end
        end
      end

      def due_now
        summary_data[:amountDueNow]
      end

      def balance
        summary_data[:accountBalance]
      end

      def overdue
        summary_data[:pastDueAmount]
      end

      def not_yet_due
        summary_data[:chargesNotYetDue]
      end

      private

      def disclaimer
        [
          "Transaction data downloaded on #{generated_date} at #{generated_time} PST.",
          'This is not an official record and information is subject to change.',
          'For the most up to date information, please visit CalCentral.'
        ].join(' ')
      end

      def summary_data
        @summary_data ||= CampusSolutions::Billing::MyActivity.new(user.uid).get_feed_internal[:feed][:summary]
      rescue NoMethodError
        {}
      end

      def billing_items
        user.billing_items.all
      end

      def generated_date
        now.strftime('%m/%d/%Y')
      end

      def generated_time
        now.strftime('%l:%M %p')
      end

      def now
        Settings.terms.fake_now || DateTime.now
      end
    end
  end
end

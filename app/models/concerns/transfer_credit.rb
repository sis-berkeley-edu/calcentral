module Concerns
  module TransferCredit
    extend self

    def is_pending_transfer_credit_review_deadline(student_id)
      review_deadline = transfer_credit_review_deadline(student_id)
      compare_dates = Proc.new do
        current_date = Settings.terms.fake_now || DateTime.now
        review_deadline && current_date <= review_deadline + 1.days
      end
      @is_pending_transfer_credit_review_deadline ||= compare_dates.call
    end

    def transfer_credit_review_deadline(student_id)
      return @transfer_credit_review_deadline if defined? @transfer_credit_review_deadline
      @transfer_credit_review_deadline ||= begin
        expiration = EdoOracle::Queries.get_transfer_credit_expiration(student_id).try(:[], 'expire_date')
        cast_utc_to_pacific(expiration) if expiration
      end
    end

  end
end

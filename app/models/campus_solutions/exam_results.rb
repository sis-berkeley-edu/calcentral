module CampusSolutions
  class ExamResults < UserSpecificModel
    include Cache::CachedFeed
    include Cache::UserCacheExpiry
    include Concerns::DatesAndTimes
    include Concerns::TransferCredit
    include User::Identifiers

    def get_feed_internal
      pending_credit_review = is_pending_transfer_credit_review_deadline(campus_solutions_id)
      response = {
        exams: transform_exam_results_values(exam_results),
        review: {
          isPending: pending_credit_review,
          displayMonth: nil
        }
      }
      response[:review].update({displayMonth: get_month(transfer_credit_review_deadline(campus_solutions_id))}) if pending_credit_review
      response
    end

    def transform_exam_results_values(results)
      results.map do |exam|
        exam = HashConverter.camelize(exam)
        exam[:score] = exam[:score].try(:to_f)
        exam[:taken] = cast_utc_to_pacific exam[:taken]
        exam
      end
    end

    def exam_results
      @exam_results ||= EdoOracle::Queries.get_exam_results(campus_solutions_id)
    end

    def campus_solutions_id
      @cs_id ||= lookup_campus_solutions_id
    end

  end
end

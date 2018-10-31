module CampusSolutions
  class HasExamResults < UserSpecificModel
    include Cache::CachedFeed
    include Cache::UserCacheExpiry
    include User::Identifiers

    def get_feed_internal
      {
        hasExamResults: has_exam_results?
      }
    end

    def has_exam_results?
      EdoOracle::Queries.has_exam_results?(campus_solutions_id)
    end

    def campus_solutions_id
      @cs_id ||= lookup_campus_solutions_id
    end

  end
end

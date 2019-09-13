module MyAcademics
  # Provides a students Career, Program, and Plans (CPP) within
  # the context of a specific term (e.g. Spring, Summer, or Fall)
  class MyTermCpp < UserSpecificModel
    include Cache::CachedFeed
    include Cache::UserCacheExpiry

    def get_feed_internal
      student_id = User::Identifiers.lookup_campus_solutions_id(@uid)
      EdoOracle::Queries.get_student_term_cpp(student_id)
    end
  end
end

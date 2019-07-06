module User
  class HasStudentHistory < UserSpecificModel

    extend Cache::Cacheable
    include Cache::UserCacheExpiry

    def has_student_history?(current_terms=nil)
      self.class.fetch_from_cache @uid do
        grouped_terms = Berkeley::Terms.legacy_group(current_terms)
        EdoOracle::Queries.has_student_history?(@uid, grouped_terms[:sisedo])
      end
    end
  end
end

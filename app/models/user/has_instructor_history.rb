module User
  class HasInstructorHistory < UserSpecificModel

    extend Cache::Cacheable
    include Cache::UserCacheExpiry

    def has_instructor_history?(current_terms = nil)
      self.class.fetch_from_cache @uid do
        grouped_terms = Berkeley::Terms.legacy_group(current_terms)
        has_legacy_instructor_history = Proc.new { CampusOracle::Queries.has_instructor_history?(@uid, grouped_terms[:legacy]) }
        has_sisedo_instructor_history = Proc.new { EdoOracle::Queries.has_instructor_history?(@uid, grouped_terms[:sisedo]) }
        (Settings.features.allow_legacy_fallback && has_legacy_instructor_history.call) || has_sisedo_instructor_history.call
      end
    end
  end
end

module User
  class HasInstructorHistory < UserSpecificModel

    extend Cache::Cacheable
    include Cache::UserCacheExpiry

    def has_instructor_history?(current_terms = nil)
      self.class.fetch_from_cache "#{@uid}-" + (current_terms && current_terms.collect {|t| t.slug}).to_s do
        grouped_terms = Berkeley::Terms.legacy_group(current_terms)
        has_legacy_instructor_history = Proc.new do
          # If no terms are specified, the query will search all terms by default.
          if grouped_terms[:legacy]
            CampusOracle::Queries.has_instructor_history?(@uid, grouped_terms[:legacy])
          else
            false
          end
        end
        has_sisedo_instructor_history = Proc.new do
          if grouped_terms[:sisedo]
            EdoOracle::Queries.has_instructor_history?(@uid, grouped_terms[:sisedo])
          else
            false
          end
        end
        (Settings.features.allow_legacy_fallback && has_legacy_instructor_history.call) || has_sisedo_instructor_history.call
      end
    end
  end
end

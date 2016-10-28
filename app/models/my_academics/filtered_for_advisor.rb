module MyAcademics
  class FilteredForAdvisor < UserSpecificModel
    include Cache::CachedFeed
    include Cache::JsonifiedFeed
    include MergedModel

    # Advisors do not see Teaching or Course Website (aka CanvasSites) data.
    def self.providers
      [
        CollegeAndLevel,
        TransitionTerm,
        GpaUnits,
        Semesters,
        TransferCredit,
        Exams
      ]
    end

    def get_feed_internal
      feed = {}
      handling_provider_exceptions(feed, self.class.providers) do |provider|
        provider.new(@uid).merge feed
      end
      feed
    end

  end
end

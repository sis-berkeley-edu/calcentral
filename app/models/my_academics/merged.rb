module MyAcademics
  class Merged < UserSpecificModel
    include Cache::CachedFeed
    include Cache::UserCacheExpiry
    include Cache::JsonifiedFeed
    include MergedModel

    def self.providers
      # Provider ordering is significant! Semesters/Teaching must be merged before course sites.
      # CollegeAndLevel must be merged before TransitionTerm.
      # Grading must be merged after Teaching.
      # All current providers draw from separately cached sources.
      [
        CollegeAndLevel,
        TransitionTerm,
        GpaUnits,
        Requirements,
        Semesters,
        Teaching,
        Exams,
        CanvasSites,
        Grading
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

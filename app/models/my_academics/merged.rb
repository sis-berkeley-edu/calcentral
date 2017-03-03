module MyAcademics
  class Merged < UserSpecificModel
    include Cache::CachedFeed
    include Cache::UserCacheExpiry
    include Cache::JsonifiedFeed
    include MergedModel

    def self.providers
      # Provider ordering is significant!
      # Semesters/Teaching must be merged before course sites.
      # FacultyDelegate must be after Teaching.
      # Grading must be merged after Teaching and FacultyDelegate.
      # All current providers draw from separately cached sources.
      [
        CollegeAndLevel,
        GpaUnits,
        Semesters,
        TransferCredit,
        Teaching,
        Exams,
        CanvasSites,
        FacultyDelegate,
        Grading,
        StudentLinks
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

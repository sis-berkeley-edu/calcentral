module DegreeProgress
  class GraduateMilestones < UserSpecificModel
    # This model provides an advisor-specific version of milestone data for GRAD and LAW career.

    include Cache::CachedFeed
    include Cache::JsonifiedFeed
    include Cache::UserCacheExpiry
    include CampusSolutions::DegreeProgressFeatureFlagged
    include MilestonesModule

    def get_feed_internal
      return {} unless is_feature_enabled
      response = CampusSolutions::DegreeProgress::GraduateMilestones.new(user_id: @uid).get
      response[:feed] = HashConverter.camelize({
        degree_progress: process(response),
      })
      response
    end
  end
end

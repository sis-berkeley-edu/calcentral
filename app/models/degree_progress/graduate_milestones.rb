module DegreeProgress
  class GraduateMilestones < UserSpecificModel
    # This model provides an advisor-specific version of milestone data for GRAD and LAW career.

    include Cache::CachedFeed
    include Cache::JsonifiedFeed
    include Cache::UserCacheExpiry
    include CampusSolutions::DegreeProgressGradAdvisingFeatureFlagged
    include MilestonesModule

    def get_feed_internal
      return {} unless is_feature_enabled && authorized?
      response = CampusSolutions::DegreeProgress::GraduateMilestones.new(user_id: @uid).get
      response[:feed] = HashConverter.camelize({
        degree_progress: process(response),
      })
      response
    end

    def authorized?
      authentication_state.policy.can_view_as?
    end
  end
end

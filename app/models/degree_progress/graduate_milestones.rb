module DegreeProgress
  class GraduateMilestones < UserSpecificModel
    # This model provides an advisor-specific version of milestone data for GRAD and LAW career.
    # TODO Could be replaced by adding FilterJsonOutput to a shared cached feed.

    include Cache::CachedFeed
    include Cache::JsonifiedFeed
    include Cache::UserCacheExpiry
    include MilestonesModule

    def get_feed_internal
      return {} unless is_feature_enabled?
      response = CampusSolutions::DegreeProgress::GraduateMilestones.new(user_id: @uid).get
      if response[:errored] || response[:noStudentId]
        response[:feed] = {}
      else
        response[:feed] = {
          degreeProgress: process(response),
        }
      end
      response
    end

    private

    def is_feature_enabled?
      Settings.features.cs_degree_progress_grad_advising
    end
  end
end

module DegreeProgress
  class GraduateMilestones < UserSpecificModel
    # This model provides an advisor-specific version of milestone data for GRAD and LAW career.
    # TODO Could be replaced by adding FilterJsonOutput to a shared cached feed.

    include Cache::CachedFeed
    include Cache::JsonifiedFeed
    include Cache::UserCacheExpiry

    def get_feed_internal
      return {} unless is_feature_enabled?
      user = User::Current.new(@uid)
      degree_progress = User::Academics::DegreeProgress::Graduate::Milestones.new(user).as_json
      response = {feed: {}}
      response[:feed][:degreeProgress] = degree_progress if degree_progress.present?
      response
    end

    private

    def is_feature_enabled?
      Settings.features.cs_degree_progress_grad_advising
    end
  end
end

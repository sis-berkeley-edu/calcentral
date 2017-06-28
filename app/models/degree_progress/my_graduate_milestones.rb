module DegreeProgress
  class MyGraduateMilestones < UserSpecificModel
    # This model provides a student-specific version of milestone data for GRAD and LAW career.

    include Cache::CachedFeed
    include Cache::JsonifiedFeed
    include Cache::UserCacheExpiry
    include MilestonesModule
    include LinkFetcher

    def get_feed_internal
      return {} unless is_feature_enabled? && target_audience?
      response = CampusSolutions::DegreeProgress::GraduateMilestones.new(user_id: @uid).get
      response[:feed] = HashConverter.camelize({
        degree_progress: process(response)
      })
      response
    end

    private

    def target_audience?
      User::SearchUsersByUid.new(id: @uid, roles: [:graduate, :law, :exStudent]).search_users_by_uid.present?
    end

    def is_feature_enabled?
      Settings.features.cs_degree_progress_grad_student
    end
  end
end

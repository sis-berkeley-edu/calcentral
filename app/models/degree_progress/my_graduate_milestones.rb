module DegreeProgress
  class MyGraduateMilestones < UserSpecificModel
    # This model provides a student-specific version of milestone data for GRAD and LAW career.

    include Cache::CachedFeed
    include Cache::JsonifiedFeed
    include Cache::UserCacheExpiry

    def get_feed_internal
      return {} unless is_feature_enabled? && target_audience?
      user = User::Current.new(@uid)
      degree_progress = User::Academics::DegreeProgress::Graduate::Milestones.new(user).as_json
      response = {
        statusCode: 200,
        feed: {}
      }
      if degree_progress
        response[:feed][:degree_progress] = degree_progress
        response[:feed][:links] = User::Academics::DegreeProgress::Graduate::StudentLinks.new(user).links
      end
      HashConverter.camelize response
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

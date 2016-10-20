module DegreeProgress
  class UndergradRequirements < UserSpecificModel
    # This model provides an advisor-specific version of milestone data for UGRD career.

    include Cache::CachedFeed
    include Cache::JsonifiedFeed
    include Cache::UserCacheExpiry
    include CampusSolutions::DegreeProgressUgrdAdvisingFeatureFlagged
    include RequirementsModule

    def get_feed_internal
      return {} unless is_feature_enabled
      response = CampusSolutions::DegreeProgress::UndergradRequirements.new(user_id: @uid).get
      if response[:errored]
        response[:feed] = {}
      else
        response[:feed] = HashConverter.camelize({
          degree_progress: process(response),
        })
      end
      response
    end
  end
end

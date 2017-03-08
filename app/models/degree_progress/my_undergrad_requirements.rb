module DegreeProgress
  class MyUndergradRequirements < UserSpecificModel
    # This model provides an student-specific version of milestone data for UGRD career.
    # TODO Could be replaced by adding FilterJsonOutput to a shared cached feed.
    include Cache::CachedFeed
    include Cache::JsonifiedFeed
    include Cache::UserCacheExpiry
    include RequirementsModule

    def get_feed_internal
      return {} unless is_feature_enabled?
      response = CampusSolutions::DegreeProgress::UndergradRequirements.new(user_id: @uid).get
      if response[:errored] || response[:noStudentId]
        response[:feed] = {}
      else
        response[:feed] = HashConverter.camelize({
          degree_progress: process(response),
        })
      end
      response
    end

    private

    def is_feature_enabled?
      Settings.features.cs_degree_progress_ugrd_student
    end
  end
end

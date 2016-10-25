module CampusSolutions
  module DegreeProgressUgrdAdvisingFeatureFlagged
    def is_feature_enabled
      Settings.features.cs_degree_progress_ugrd_advising
    end
  end
end

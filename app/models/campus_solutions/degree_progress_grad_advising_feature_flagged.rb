module CampusSolutions
  module DegreeProgressGradAdvisingFeatureFlagged
    def is_feature_enabled
      Settings.features.cs_degree_progress_grad_advising
    end
  end
end

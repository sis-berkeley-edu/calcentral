module CampusSolutions
  module DegreeProgressGradStudentFeatureFlagged
    def is_feature_enabled
      Settings.features.cs_degree_progress_grad_student
    end
  end
end

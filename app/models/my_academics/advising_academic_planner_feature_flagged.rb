module MyAcademics
  module AdvisingAcademicPlannerFeatureFlagged
    def is_feature_enabled
      Settings.features.advising_academic_planner
    end
  end
end

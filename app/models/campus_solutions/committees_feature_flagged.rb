module CampusSolutions
  module CommitteesFeatureFlagged
    def is_feature_enabled
      Settings.features.cs_committees
    end
  end
end

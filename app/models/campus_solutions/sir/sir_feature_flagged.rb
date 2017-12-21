module CampusSolutions
  module Sir
    module SirFeatureFlagged
      def is_feature_enabled
        Settings.features.cs_sir
      end
    end
  end
end

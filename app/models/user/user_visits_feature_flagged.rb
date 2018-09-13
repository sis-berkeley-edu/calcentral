module User
  module UserVisitsFeatureFlagged
    def is_feature_enabled
      Settings.features.user_visits
    end

    def self.included(base)
      base.extend ClassMethods
    end

    module ClassMethods
      def is_feature_enabled
        Settings.features.user_visits
      end
    end
  end
end

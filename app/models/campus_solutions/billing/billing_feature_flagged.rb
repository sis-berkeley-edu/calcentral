module CampusSolutions
  module Billing
    module BillingFeatureFlagged
      def is_feature_enabled
        Settings.features.cs_billing
      end
    end
  end
end

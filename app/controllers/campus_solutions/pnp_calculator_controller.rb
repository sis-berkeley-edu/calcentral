module CampusSolutions
  class PnpCalculatorController < CampusSolutionsController
    include AllowDelegateViewAs

    def get_calculator_values
      render json: CampusSolutions::PnpCalculator::CalculatorValues.from_session(session).get_feed
    end

    def get_ratio_message
      render json: CampusSolutions::MessageCatalog.get_message(:pnp_calculator_ratio)
    end
  end
end

module CampusSolutions
  class PnpCalculatorController < CampusSolutionsController
    include AllowDelegateViewAs

    def get_calculator_values
      render json: CampusSolutions::PnpCalculator::CalculatorValues.from_session(session).get_feed
    end

    def get_ratio_message
        render json: CampusSolutions::MessageCatalog.get_message_catalog_definition(message_set_nbr = 32000, message_nbr = 17)
    end

  end
end

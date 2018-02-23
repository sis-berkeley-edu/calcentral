module CampusSolutions
  class FinancialResourcesController < ApplicationController

    before_action :api_authenticate

    def get_general
      render json: CampusSolutions::FinancialResourcesGeneral.new().get_feed
    end

    def get_parameterized
      aid_year = aid_year_param
      render json: CampusSolutions::FinancialResourcesParameterized.new({aid_year: aid_year}).get_feed
    end

    private

    def aid_year_param
      params.require 'aid_year'
    end

  end
end

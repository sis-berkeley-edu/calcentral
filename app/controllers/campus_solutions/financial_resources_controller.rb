module CampusSolutions
  class FinancialResourcesController < ApplicationController
    before_action :api_authenticate

    def get_emergency_loan
      render json: CampusSolutions::EmergencyLoanLink.new().get_feed
    end

    def get_financial_aid_summary
      render json: CampusSolutions::FinancialAidSummaryLink.new().get_feed
    end

    def get_summer_estimator
      render json: CampusSolutions::SummerEstimatorLink.new().get_feed
    end

  end
end

class FinancialResourcesController < ApplicationController
  include AllowDelegateViewAs
  before_filter :api_authenticate_401
  before_filter :authorize_for_financial

  def get_feed
    render json: FinancialAid::FinancialResources.new().get_feed
  end
end

class MyAwardsController < ApplicationController
  include AllowDelegateViewAs
  before_action :api_authenticate_401
  before_action :authorize_for_financial

  def get_feed
    render json: FinancialAid::MyAwards.from_session(session, options).get_feed_as_json
  end

  private

  def options
    params.permit(:aid_year)
  end
end

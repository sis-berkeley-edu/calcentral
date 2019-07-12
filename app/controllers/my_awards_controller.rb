class MyAwardsController < ApplicationController
  include AllowDelegateViewAs
  before_filter :api_authenticate_401
  before_filter :authorize_for_financial

  def get_feed
    options = params.permit :aid_year
    render json: FinancialAid::MyAwards.from_session(session, options).get_feed_as_json
  end
end

class MyAwardsByTermController < ApplicationController
  include AllowDelegateViewAs
  before_action :api_authenticate_401
  before_action :authorize_for_financial

  def get_feed
    options = params.permit :aid_year
    render json: FinancialAid::MyAwardsByTerm.from_session(session, options).get_feed_as_json
  end
end

class MyFinancialsController < ApplicationController
  include AllowDelegateViewAs
  before_action :api_authenticate
  before_action :authorize_for_financial

  def get_feed
    render json: Financials::MyFinancials.from_session(session).get_feed
  end

end

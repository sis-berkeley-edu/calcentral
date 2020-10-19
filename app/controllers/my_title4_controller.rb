class MyTitle4Controller < ApplicationController
  include AllowDelegateViewAs
  before_action :api_authenticate_401
  before_action :authorize_for_financial

  def get_feed
    render json: FinancialAid::MyTitle4.from_session(session).get_feed_as_json
  end
end

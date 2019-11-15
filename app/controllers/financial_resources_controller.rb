class FinancialResourcesController < ApplicationController
  include AllowDelegateViewAs
  before_filter :api_authenticate_401
  before_filter :authorize_for_financial

  def get_feed
    render json: {
      links: FinancialAid::FinancialResources.new().get_feed,
      matriculated: user.matriculated?
    }
  end

  private

  def user
    User::Current.new(session['user_id'])
  end
end

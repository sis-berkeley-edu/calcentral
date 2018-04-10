class NewAdmitResourcesController < ApplicationController
  before_filter :api_authenticate, :require_released_admit_role

  def get_feed
    render json: CampusSolutions::NewAdmitResources.from_session(session).get_feed
  end

end

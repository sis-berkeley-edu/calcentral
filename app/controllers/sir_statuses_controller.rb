class SirStatusesController < ApplicationController
  before_action :api_authenticate, :require_released_admit_role

  def get_feed
    render json: CampusSolutions::Sir::SirStatuses.from_session(session).get_feed
  end

end

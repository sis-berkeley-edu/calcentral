class SirStatusesController < ApplicationController
  before_filter :api_authenticate, :require_applicant_role

  def get_feed
    render json: CampusSolutions::Sir::SirStatuses.from_session(session).get_feed
  end

end

class SirStatusesController < ApplicationController
  before_filter :api_authenticate, :require_applicant_role

  def get_feed
    render json: CampusSolutions::Sir::SirStatuses.from_session(session).get_feed
  end

  def require_applicant_role
    is_applicant = HubEdos::UserAttributes.new(user_id: current_user.user_id).has_role?(:applicant)
    render json: { error: 'User must be an applicant to view New Admit data.' }, status: 200 unless is_applicant
  end

end

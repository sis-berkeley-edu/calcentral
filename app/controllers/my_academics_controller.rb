class MyAcademicsController < ApplicationController
  include AllowDelegateViewAs
  before_action :api_authenticate
  before_action :authorize_for_enrollments

  def get_feed
    if current_user.authenticated_as_delegate?
      render json: MyAcademics::FilteredForDelegate.from_session(session).get_feed_as_json
    elsif current_user.authenticated_as_advisor?
      render json: MyAcademics::FilteredForAdvisor.from_session(session).get_feed_as_json
    else
      render json: MyAcademics::Merged.from_session(session).get_feed_as_json
    end
  end

  def residency
    if current_user.authenticated_as_delegate?
      render json: {}
    else
      render json: MyAcademics::Residency.from_session(session).get_feed_as_json
    end
  end

end

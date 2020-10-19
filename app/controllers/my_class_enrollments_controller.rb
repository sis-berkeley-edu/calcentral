class MyClassEnrollmentsController < ApplicationController
  include AllowDelegateViewAs
  before_action :api_authenticate_401
  before_action :authorize_for_enrollments

  def get_feed
    if params[:expireCache]
      MyAcademics::ClassEnrollments.expire(session['uid'])
    end

    render json: MyAcademics::ClassEnrollments.from_session(session).get_feed_as_json
  end
end

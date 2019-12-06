class MyEftEnrollmentController < ApplicationController
  include AllowDelegateViewAs

  before_action :authorize_for_financial

  def get_feed
    render json: Eft::MyEftEnrollment.from_session(session).get_feed_as_json
  end
end

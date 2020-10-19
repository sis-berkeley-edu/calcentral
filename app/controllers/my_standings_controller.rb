class MyStandingsController < ApplicationController
  include AllowDelegateViewAs
  before_action :api_authenticate_401

  def get_feed
    render json: MyAcademics::MyStandings.from_session(session).get_feed_as_json
  end

end

class AlumniProfilesController < ApplicationController
  include AllowDelegateViewAs
  before_action :api_authenticate_401

  def get_feed
    render json: HashConverter.camelize(Api::AlumniProfiles.from_session(session).get_feed).to_json
  end

  def set_skip_landing_page
    render json: Api::AlumniProfiles.from_session(session).set_skip_landing_page.to_json
  end

end

class MyUpNextController < ApplicationController

  before_filter :api_authenticate
  rescue_from StandardError, with: :handle_api_exception

  def get_feed
    render :json => UpNext::MyUpNext.from_session(session).get_feed_as_json
  end

end

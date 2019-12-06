class MyGroupsController < ApplicationController

  before_action :api_authenticate

  def get_feed
    render :json => MyGroups::Merged.from_session(session).get_feed_as_json
  end

end

class MyActivitiesController < ApplicationController
  include AllowDelegateViewAs
  before_action :api_authenticate
  before_action :authorize_for_financial

  def get_feed
    render :json => MyActivities::Merged.from_session(session).get_feed_as_json
  end
end

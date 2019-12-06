class MyAcademicRecordsController < ApplicationController
  before_action :api_authenticate

  def get_feed
    render json: MyAcademics::AcademicRecords.from_session(session).get_feed_as_json
  end
end


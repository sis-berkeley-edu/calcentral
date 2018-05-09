class TransferCreditController < ApplicationController
  include AllowDelegateViewAs
  before_filter :api_authenticate
  before_filter :authorize_for_enrollments

  def get_feed
    render json: MyAcademics::MyTransferCredit.from_session(session).get_feed_as_json
  end
end

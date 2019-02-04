class CalGrantAcknowledgementsController < ApplicationController
  def index
    render json: CalGrant::Acknowledgement.new(session['user_id']).get_feed
  end
end

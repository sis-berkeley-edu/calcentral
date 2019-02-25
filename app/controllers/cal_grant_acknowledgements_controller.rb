class CalGrantAcknowledgementsController < ApplicationController
  def index
    if params[:expireCache]
      CalGrant::Acknowledgement.expire(session['user_id'])
    end

    render json: CalGrant::Acknowledgement.new(session['user_id']).get_feed
  end
end

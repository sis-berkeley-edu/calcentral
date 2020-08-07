class CovidResponseController < ApplicationController
  def index
    render json: COVIDUpdates.new
  end
end

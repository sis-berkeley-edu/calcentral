class StatsController < ApplicationController

  def get_stats
    render :json => {
      :threads => Thread.list.size,
      :jms_worker => JmsWorker.ping
    }
  end

end

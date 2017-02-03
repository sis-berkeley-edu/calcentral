class TorqueboxController < ApplicationController
  include BackgroundJob
  include ClassLogger

  before_filter :check_permission

  def stats
    result = TorqueboxInspector.new().torquebox_status
    render json: {status: result}.to_json
  end

  def bg
    result = TorqueboxInspector.new().bg_status
    render json: {status: result}.to_json
  end

  def bg_msgs
    result = TorqueboxInspector.new().bg_messages
    render json: result
  end

  def bg_purge
    result = TorqueboxInspector.new().bg_purge
    render json: {status: result}.to_json
  end

  def test_no_wait
    worker = TorqueboxTester.new()
    times = params['times'] || 5
    pauses = params['pauses'] || 5
    result = worker.start_background_and_return(times, pauses)
    render json: {result: result.to_s}.to_json
  end

  def test_wait
    worker = TorqueboxTester.new()
    times = params['times'] || 5
    pauses = params['pauses'] || 5
    result = worker.start_background_and_wait(times, pauses)
    render json: {result: result.to_s}.to_json
  end

  private

  def check_permission
    authorize(current_user, :can_administrate?)
  end

end

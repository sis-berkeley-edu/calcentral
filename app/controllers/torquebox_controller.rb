class TorqueboxController < ApplicationController
  include BackgroundJob
  include ClassLogger

  before_filter :check_permission

  def stats
    result = TorqueboxInspector.new.torquebox_status
    render json: {status: result}.to_json
  end

  def bg
    result = TorqueboxInspector.new.bg_status
    render json: {status: result}.to_json
  end

  def bg_msgs
    result = TorqueboxInspector.new.bg_messages
    render json: result
  end

  def bg_purge
    result = TorqueboxInspector.new.bg_purge
    render json: {status: result}.to_json
  end

  def job
    if (background_job = BackgroundJob.find(params['id']))
      result = background_job.background_job_report
    else
      result = {error: "#{params['id']} not found"}
    end
    render json: result.to_json
  end

  def test_no_wait
    times = params['times'].present? ? params['times'].to_i : 5
    pauses = params['pauses'].present? ? params['pauses'].to_i : 5
    result = TorqueboxTester.new.start_background_and_return(times, pauses)
    render json: {result: result.to_s}.to_json
  end

  def test_wait
    times = params['times'].present? ? params['times'].to_i : 5
    pauses = params['pauses'].present? ? params['pauses'].to_i : 5
    result = TorqueboxTester.new.start_background_and_wait(times, pauses)
    render json: {result: result.to_s}.to_json
  end

  private

  def check_permission
    authorize(current_user, :can_administrate?)
  end

end

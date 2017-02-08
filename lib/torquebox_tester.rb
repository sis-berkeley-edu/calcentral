# Support tools for Torquebox diagnostics.
class TorqueboxTester
  include BackgroundJob
  include ClassLogger

  def initialize
    background_job_initialize
  end

  # Start a time-consuming background task and wait for it to complete,
  # reporting its progress.
  def start_background_and_wait(times, pauses)
    logger.warn "#{@background_job_id} About to start twiddling #{times} times with #{pauses}-second waits and will not return until done"
    background_job_set_total_steps times
    tracker = background_correlate(background.twiddle_thumbs(@background_job_id, times, pauses))
    logger.warn "#{@background_job_id} wait tracker = #{tracker}, correlation_id = #{tracker.correlation_id}"
    loop do
      logger.warn "#{@background_job_id} started = #{tracker.started?}, error = #{tracker.error?}, complete = #{tracker.complete?}, status = #{tracker.status}"
      logger.warn "Report : #{background_job_report}"
      sleep(2)
      break if tracker.complete?
    end
    logger.warn "#{@background_job_id} started = #{tracker.started?}, error = #{tracker.error?}, complete = #{tracker.complete?}, status = #{tracker.status}"
    logger.warn "Report : #{background_job_report}"
    result = tracker.result
    logger.warn "#{@background_job_id} result = #{tracker.result}"
    result
  end

  # Start a time-consuming background job and return immediately.
  def start_background_and_return(times, pauses)
    logger.warn "#{@background_job_id} About to start twiddling #{times} times with #{pauses}-second waits and will return immediately afterward"
    background_job_set_total_steps times
    tracker = background_correlate(background.twiddle_thumbs(@background_job_id, times, pauses))
    logger.warn "#{@background_job_id} twiddle tracker = #{tracker}, correlation_id = #{tracker.correlation_id}, started = #{tracker.started?}, error = #{tracker.error?}, complete = #{tracker.complete?}, status = #{tracker.status}"
    logger.warn "Report : #{background_job_report}"
    "started task #{@background_job_id}"
  end

  def twiddle_thumbs(test_id, times, pauses)
    logger.warn "#{test_id} began twiddling"
    logger.warn "From inside background job Report : #{background_job_report}"
    times.times do |i|
      future.status = (i * 100) / times
      sleep(pauses)
      logger.warn "#{test_id} waking for for i = #{i}"
      background_job_complete_step "Loop #{i}"
    end
    result = "All done with #{times} twiddles"
    logger.warn "#{test_id} #{result}"
    logger.warn "From inside background job Report : #{background_job_report}"
    result
  end

end

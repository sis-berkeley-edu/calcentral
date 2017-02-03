# Support tools for Torquebox diagnostics.
class TorqueboxTester
  include BackgroundJob
  include ClassLogger

  def initialize
    @id = "#{DateTime.now.to_s}_#{SecureRandom.hex(8)}"
  end

  # Start a time-consuming background task and wait for it to complete,
  # reporting its progress.
  def start_background_and_wait(times, pauses)
    logger.warn "#{@id} About to start twiddling and will not return until done"
    tracker = background.twiddle_thumbs(@id, times, pauses)
    logger.warn "#{@id} wait tracker = #{tracker}, correlation_id = #{tracker.correlation_id}"
    begin
      logger.warn "#{@id}  started = #{tracker.started?}, error = #{tracker.error?}, complete = #{tracker.complete?}, status = #{tracker.status}"
      sleep(2)
    end while !tracker.complete?
    logger.warn "#{@id} started = #{tracker.started?}, error = #{tracker.error?}, complete = #{tracker.complete?}, status = #{tracker.status}"
    result = tracker.result
    logger.warn "#{@id} result = #{tracker.result}"
    result
  end

  # Start a time-consuming background job and return immediately.
  def start_background_and_return(times, pauses)
    logger.warn "#{@id} About to start twiddling and will return immediately afterward"
    tracker = background.twiddle_thumbs(@id, times, pauses)
    logger.warn "#{@id} twiddle tracker = #{tracker}, correlation_id = #{tracker.correlation_id}, started = #{tracker.started?}, error = #{tracker.error?}, complete = #{tracker.complete?}, status = #{tracker.status}"
    "started task #{@id}"
  end

  def twiddle_thumbs(test_id, times, pauses)
    logger.warn "#{test_id} began twiddling"
    for i in 0..(times - 1)
      future.status = (i * 100) / times
      sleep(pauses)
      logger.warn "#{test_id}  waking for for i = #{i}"
    end
    result = "All done with #{times} twiddles"
    logger.warn "#{test_id} #{result}"
    result
  end

end

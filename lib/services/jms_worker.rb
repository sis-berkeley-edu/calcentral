class JmsWorker
  extend Cache::StatAccumulator

  JMS_RECORDING = "#{Rails.root}/fixtures/jms_recordings/ist_jms.txt"

  RECEIVED_MESSAGES = 'Received Messages'
  LAST_MESSAGE_RECEIVED_TIME = 'Last Message Received Time'

  attr_accessor :run_thread
  attr_reader :jms_connections

  # The unused opts argument is expected by Torquebox.
  def initialize(opts={})
    @handler = Notifications::JmsMessageHandler.new
    @stopped = false
  end

  def start
    if Settings.ist_jms.enabled
      Rails.logger.warn "#{self.class.name} Starting up"

      self.run_thread = Thread.new { run }

      %w(INT TERM EXIT).each do |signal|
        trap(signal) {
          self.stop
          exit 0
        }
      end
    else
      Rails.logger.warn "#{self.class.name} is disabled, not starting thread"
    end
  end

  def stop
    @stopped = true
    Rails.logger.warn "#{self.class.name} #{run_thread} is stopping"
    Rails.logger.warn "#{JmsWorker.ping}"
    Thread.kill(self.run_thread)
  end

  def run
    if Settings.ist_jms.fake
      Rails.logger.warn "#{self.class.name} Reading fake messages"
      open_fake_connection { |msg| @handler.handle(msg) }
    else
      open_jms_connections(Settings.ist_jms.connections) { |msg| @handler.handle(msg) }
    end
  end

  def open_jms_connections(connections, &blk)
    @jms_connections = []
    loop do
      failed_connections = []
      connections.each do |connection_settings|
        if (jms_connection = open_connection(connection_settings, &blk))
          @jms_connections << jms_connection
        else
          failed_connections << connection_settings
        end
      end
      if failed_connections.any?
        # Spell out 30.minutes in seconds because sleep and ActiveSupport are not friends in JRuby 1.7.19
        # https://github.com/jruby/jruby/issues/1856
        sleep 1800
        connections = failed_connections
      else
        break
      end
    end
  end

  def open_connection(connection_settings)
    begin
      jms_connection = JmsConnection.new(connection_settings)
    rescue => e
      Rails.logger.error "#{self.class.name} Unable to start JMS listener at #{connection_settings.url}: #{e.class} #{e.message}"
      return false
    end
    Rails.logger.warn "#{self.class.name} JMS Connection is initialized at #{connection_settings.url}"
    jms_connection.start_listening_with() do |msg|
      if Settings.ist_jms.freshen_recording
        File.open(JMS_RECORDING, 'a') do |f|
          # Use double newline as a serialized object separator.
          # Hat tip to: http://www.skorks.com/2010/04/serializing-and-deserializing-objects-with-ruby/
          f.puts YAML.dump(msg)
          f.puts ''
        end
      end
      write_stats
      yield msg
    end
    jms_connection
  end

  def open_fake_connection
    File.open(JMS_RECORDING, 'r').each("\n\n") do |msg_yaml|
      msg = YAML::load(msg_yaml)
      write_stats
      yield msg
    end
  end

  def write_stats
    self.class.increment(RECEIVED_MESSAGES, 1)
    self.class.write(LAST_MESSAGE_RECEIVED_TIME, Time.zone.now)
  end

  def self.ping
    received_messages = self.get_value RECEIVED_MESSAGES
    last_received_message_time = self.get_value LAST_MESSAGE_RECEIVED_TIME
    server = ServerRuntime.get_settings['hostname']
    if received_messages || last_received_message_time
      {
        server: server,
        received_messages: received_messages,
        last_received_message_time: last_received_message_time
      }
    else
      "#{self.name} Running on #{server}; Stats are not available"
    end
  end
end

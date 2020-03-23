require 'singleton'

module ENF
  class Processor
    include Singleton

    attr_accessor :topic_handlers

    def initialize
      self.topic_handlers = {}
    end

    def reset
      self.topic_handlers = {}
    end

    def register(topic, klass)
      topic_handlers.fetch(topic) { topic_handlers[topic] = [] }.tap do |handlers|
        handlers << klass unless handlers.include? klass
      end
    end

    def handle(message_data)
      message = Message.new(message_data)
      dispatch(message.topic, message)
    end

    def dispatch(topic, message)
      handlers = topic_handlers.fetch(topic) { [] }
      handlers.each do |handler|
        handler.call(message)
      end
    end
  end
end

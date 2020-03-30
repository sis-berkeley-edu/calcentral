module ENF
  class Handler
    attr_accessor :message

    def self.call(message)
      raise "Override self.call in your subclass"
    end

    def initialize(message)
      self.message = message
    end

    def uid
      message.student_uid
    end
  end
end

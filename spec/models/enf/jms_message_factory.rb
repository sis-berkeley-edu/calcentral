class JMSMessageFactory
  def initialize(topic, payload)
    @topic = topic
    @payload = payload
  end

  def generate
    ENF::Message.new(to_h)
  end

  def to_h
    {
      text: text,
      timestamp: Time.now
    }
  end

  private

  def text
    JSON.generate({
      eventNotification: {
        event: {
          payload: @payload,
          topic: @topic
        }
      }
    })
  end
end

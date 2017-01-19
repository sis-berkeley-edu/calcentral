Rails.application.config.after_initialize do
  # send a message to warm up the message queues on app start
  if Settings.application.provided_services.include? 'calcentral'
    Messaging.publish('/queues/hot_plate')
    Messaging.publish('/queues/warmup_request')
    Messaging.publish('/queues/feed_changed')
  end
end

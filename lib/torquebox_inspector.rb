# Reports on and (to some extent) controls Torquebox internal operations.
class TorqueboxInspector
  include ClassLogger

  # Returns key data about the Backgroundable job processor.
  def bg_status
    {
      processor_status: bg_message_processor['Status'],
      concurrency: bg_message_processor['Concurrency'],
      durable: bg_queue['Durable'],
      paused: bg_queue['Paused'],
      # Number of messages ever received?
      messages_added: bg_queue['MessagesAdded'],
      # Number of messages in queue?
      messages_in_queue: bg_queue['MessageCount'],
      # Number of messages being delivered to consumers (not yet acknowledged or blocking because the consumer is busy)
      delivering_count: bg_queue['DeliveringCount']
    }
  end

  # Returns obscure descriptions of the tasks currently queued for the Backgroundable job processor,
  # particularly their Correlation IDs. The list will not include pending tasks which haven't yet
  # made it onto the queue.
  def bg_messages
    messages = bg_queue.listMessagesAsJSON('')
    logger.warn("messages = #{messages}")
    messages
  end

  # Removes all pending tasks from the Backgroundable job processor.
  # USE ONLY IN CASE OF EMERGENCY!
  def bg_purge
    logger.warn "About to purge background queue with #{bg_queue['MessageCount']} messages, #{bg_queue['MessagesAdded']} already received}"
    purged_count = bg_queue.removeMessages('')
    logger.error "Purged #{purged_count} messages"
    {
      purged_count: purged_count
    }
  end

  # Introspects and reports all accessible attributes and operations of Torquebox Message Processors,
  # Topics, Queues, Services, and Runtime Pools.
  def torquebox_status
    results = {}

    # Message Processors
    message_processor_names = jmx_server.query_names('torquebox.messaging.processors:*')
    results[:message_processors] = mbeans_hashes(message_processor_names)

    # Topics
    topics_names = jmx_server.query_names('org.hornetq:address="jms.topic.*",*,name="jms.topic.*",type=Queue')
    results[:topics] = mbeans_hashes(topics_names)

    # Queues
    queue_names = jmx_server.query_names('org.hornetq:address="jms.queue.*",*,type=Queue')
    results[:queues] = mbeans_hashes(queue_names)

    # Services
    services_names = jmx_server.query_names('torquebox.services:*')
    results[:services] = mbeans_hashes(services_names)

    # Runtime Pools
    pools_names = jmx_server.query_names('torquebox.pools:*')
    results[:pools] = mbeans_hashes(pools_names)

    logger.warn("Torquebox status = #{results}")
    results
  end

  def jmx_server
    @jmx_server ||= JMX::MBeanServer.new
  end

  def bg_message_processor
    @bg_message_processor ||= begin
      # Full name is 'torquebox.messaging.processors:name=/queues/torquebox/calcentral/tasks/torquebox_backgroundable/torque_box/messaging/backgroundable_processor,app=calcentral'
      message_processor_names = jmx_server.query_names('torquebox.messaging.processors:*')
      bg_name = message_processor_names.select {|name| name.to_s.include? 'torquebox_backgroundable'}.first
      jmx_server[bg_name]
    end
  end

  def bg_queue
    @bg_queue ||= begin
      # Full name is 'org.hornetq:module=Core,type=Queue,address=\"jms.queue./queues/torquebox/calcentral/tasks/torquebox_backgroundable\",name=\"jms.queue./queues/torquebox/calcentral/tasks/torquebox_backgroundable\"'
      destrination_name = bg_message_processor['DestinationName']
      queue_name = "org.hornetq:module=Core,type=Queue,address=\"jms.queue.#{destrination_name}\",name=\"jms.queue.#{destrination_name}\""
      jmx_server[queue_name]
    end
  end

  def mbean_hash(jmx_name)
    mbean = jmx_server[jmx_name]
    attributes = Hash[mbean.attributes.collect { |attr| [attr, mbean[attr]]}]
    {
      name: jmx_name.to_s,
      attributes: attributes,
      operations: mbean.operations
    }
  end

  def mbeans_hashes(jmx_names)
    jmx_names.collect { |jmx_name| mbean_hash(jmx_name) }
  end

end

class Api::ServiceAlerts
  include Cache::CachedFeed
  include Cache::JsonifiedFeed

  def get_feed_internal
    ServiceAlert.public_feed
  end

  def instance_key
    'service_alerts'
  end
end

class Api::ServiceAlerts
  include Cache::CachedFeed
  include Cache::JsonifiedFeed

  def get_feed_internal
    ServiceAlert.public_feed
  end

  # Instance key needs to be defined, but return nil for single "class instance"
  # cache to expire properly.
  def instance_key
  end
end

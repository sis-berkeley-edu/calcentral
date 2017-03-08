module ServiceAlerts
  class Merged
    include Cache::CachedFeed
    include Cache::JsonifiedFeed

    def get_feed_internal
      feed = {}
      feed[:releaseNote] = if (latest_splash = ServiceAlerts::Alert.get_latest_splash)
        latest_splash.to_feed
      else
        EtsBlog::ReleaseNotes.new.get_latest
      end
      if (latest_alert = ServiceAlerts::Alert.get_latest)
        feed[:alert] = latest_alert.to_feed
      end
      feed
    end

    def instance_key
      nil
    end

  end
end

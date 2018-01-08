module CampusSolutions
  class MyHigherOneUrl < UserSpecificModel

    include ClassLogger
    include Cache::CachedFeed
    include Cache::UserCacheExpiry
    include Cache::JsonifiedFeed

    def get_feed_internal
      proxy.get
    end

    def get_higher_one_url
      url = proxy.build_url
      url && url.strip
    end

    private

    def proxy
      proxy_args = {
        user_id: @uid,
        delegate_uid: @options[:delegate_uid]
      }
      CampusSolutions::HigherOneUrl.new(proxy_args)
    end

  end
end

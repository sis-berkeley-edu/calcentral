module CampusSolutions
  class MyHigherOneUrl < UserSpecificModel

    include ClassLogger
    include Cache::CachedFeed
    include Cache::UserCacheExpiry
    include Cache::JsonifiedFeed
    include CampusSolutions::Sir::SirFeatureFlagged

    def get_feed_internal
      return {} unless is_feature_enabled
      proxy.get
    end

    def get_higher_one_url
      return {} unless is_feature_enabled
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

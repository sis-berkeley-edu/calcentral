module HubEdos
  class MyStudent < UserSpecificModel

    include ClassLogger
    include Cache::CachedFeed
    include Cache::UserCacheExpiry
    # Needed to expire cache entries specific to Viewing-As users alongside original user's cache.
    include Cache::RelatedCacheKeyTracker
    include CampusSolutions::ProfileFeatureFlagged
    # This feed is currently used only by front-end code and is cached in multiple view-as flavors.
    # That combination means a little CPU time can be gained by caching only the JSON output.
    include Cache::JsonifiedFeed

    PROXIES = [
      HubEdos::PersonApi::V1::SisPerson,
      HubEdos::StudentApi::V2::Contacts,
      HubEdos::StudentApi::V2::Demographics,
      HubEdos::StudentApi::V2::Gender,
    ]

    def get_feed_internal
      merged = {
        feed: {},
        statusCode: 200
      }
      return merged unless is_cs_profile_feature_enabled

      proxy_options = @options.merge(user_id: @uid)
      merge_proxy_feeds(merged, proxy_options)
      merge_links(merged)

      # When we don't have any identifiers for this student, we should send a 404 to the front-end
      if !merged[:errored] && !merged[:feed]['identifiers']
        merged[:statusCode] = 404
        merged[:errored] = true
        logger.warn("No identifiers found for student feed uid #{@uid} with feed #{merged}")
      end

      merged
    end

    def merge_links(feed_hash)
      feed_hash[:feed][:links] = MyProfile::EditLink.new(@uid).get_feed.try(:[], :feed)
    end

    def merge_proxy_feeds(feed_hash, proxy_options)
      PROXIES.each do |proxy|
        response = proxy.new(proxy_options).get
        if response[:errored]
          feed_hash[:statusCode] = 500
          feed_hash[:errored] = true
          logger.error("Got errors in merged student feed on #{proxy} for uid #{@uid} with response #{response}")
        else
          feed_hash[:feed].merge!(response[:feed])
        end
      end
      feed_hash
    end

    def instance_key
      Cache::KeyGenerator.per_view_as_type @uid, @options
    end
  end
end

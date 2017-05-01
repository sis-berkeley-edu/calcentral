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

    def get_feed_internal
      merged = {
        feed: {
          student: {}
        },
        statusCode: 200
      }
      return merged unless is_cs_profile_feature_enabled

      proxy_options = @options.merge user_id: @uid
      [HubEdos::Contacts, HubEdos::Demographics, HubEdos::Gender, HubEdos::Affiliations].each do |proxy|
        break if (proxy == HubEdos::Affiliations) && merged[:feed][:student]['affiliations'].present?
        hub_response = proxy.new(proxy_options).get
        if hub_response[:errored]
          merged[:statusCode] = 500
          merged[:errored] = true
          logger.error("Got errors in merged student feed on #{proxy} for uid #{@uid} with response #{hub_response}")
        else
          merged[:feed][:student].merge!(hub_response[:feed]['student'])
        end
      end

      # When we don't have any identifiers for this student, we should send a 404 to the front-end
      if !merged[:errored] && !merged[:feed][:student]['identifiers']
        merged[:statusCode] = 404
        merged[:errored] = true
        logger.warn("No identifiers found for student feed uid #{@uid} with feed #{merged}")
      end

      merged
    end

    def instance_key
      Cache::KeyGenerator.per_view_as_type @uid, @options
    end

  end
end

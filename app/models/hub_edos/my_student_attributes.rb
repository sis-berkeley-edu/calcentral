module HubEdos
  class MyStudentAttributes < UserSpecificModel

    include ClassLogger
    include Cache::CachedFeed
    include Cache::JsonifiedFeed
    include Cache::UserCacheExpiry

    def get_feed_internal
      HubEdos::StudentAttributes.new({user_id: @uid}).get
    end

  end
end

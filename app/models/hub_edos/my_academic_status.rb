module HubEdos
  class MyAcademicStatus < UserSpecificModel

    include ClassLogger
    include Cache::CachedFeed
    include Cache::JsonifiedFeed
    include Cache::UserCacheExpiry

    def get_feed_internal
      HubEdos::AcademicStatus.new({user_id: @uid}).get
    end

  end
end

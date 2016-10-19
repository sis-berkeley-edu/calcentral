module CampusSolutions
  class MyCsOfficialTranscript < UserSpecificModel

    include Cache::CachedFeed
    include Cache::UserCacheExpiry

    def get_feed_internal
      CampusSolutions::CsOfficialTranscript.new(user_id: @uid).get
    end

  end
end

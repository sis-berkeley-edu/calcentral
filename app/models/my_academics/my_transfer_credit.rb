module MyAcademics
  class MyTransferCredit < UserSpecificModel
    include Cache::CachedFeed
    include Cache::JsonifiedFeed
    include Cache::UserCacheExpiry

    def get_feed_internal
      EdoOracle::TransferCredit.new(user_id: @uid).get_feed
    end

  end
end

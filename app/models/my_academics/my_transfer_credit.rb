module MyAcademics
  class MyTransferCredit < UserSpecificModel
    include Cache::CachedFeed
    include Cache::JsonifiedFeed
    include Cache::UserCacheExpiry

    # TODO: Once we can incorporate the EdoOracle transfer credit views for the Transfer Credit card,
    # slated for v99, we should remove this isolated class and insert this data into the merged feed instead.
    # Currently, this data will only be used for the Academic Summary card.
    def get_feed_internal
      EdoOracle::TransferCredit.new(user_id: @uid).get_feed
    end

  end
end

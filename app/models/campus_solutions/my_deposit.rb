module CampusSolutions
  class MyDeposit < UserSpecificModel

    include ClassLogger
    include Cache::CachedFeed
    include Cache::UserCacheExpiry
    include Cache::JsonifiedFeed
    include Cache::RelatedCacheKeyTracker
    include CampusSolutions::Sir::SirFeatureFlagged

    attr_accessor :adm_appl_nbr

    def get_feed_internal
      return {} unless is_feature_enabled && HubEdos::UserAttributes.new(user_id: @uid).has_role?(:applicant)
      logger.debug "User #{@uid}; aid adm_appl_nbr #{adm_appl_nbr}"
      CampusSolutions::Deposit.new({user_id: @uid, adm_appl_nbr: adm_appl_nbr}).get
    end

    def instance_key
      "#{@uid}-#{adm_appl_nbr}"
    end

  end
end

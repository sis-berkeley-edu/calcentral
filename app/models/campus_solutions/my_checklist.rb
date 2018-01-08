module CampusSolutions
  class MyChecklist < UserSpecificModel

    include Cache::CachedFeed
    include Cache::UserCacheExpiry

    def get_feed_internal
      return {} unless HubEdos::UserAttributes.new(user_id: @uid).has_role?(:applicant, :student)
      CampusSolutions::Checklist.new({user_id: @uid}).get
    end

  end
end

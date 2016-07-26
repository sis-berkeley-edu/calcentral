module CampusSolutions
  class MyEnrollmentTerms < UserSpecificModel

    include Cache::CachedFeed
    include Cache::UserCacheExpiry
    include EnrollmentCardFeatureFlagged

    def get_feed_internal
      return {} unless is_feature_enabled && HubEdos::UserAttributes.new(user_id: @uid).has_role?(:student)
      CampusSolutions::EnrollmentTerms.new({user_id: @uid}).get
    end

    def default_term_id
      feed = self.get_feed
      if (terms = feed && feed[:feed] && feed[:feed][:ucSrEnrollmentTerms])
        terms.first.try(:[], :id)
      end
    end

  end
end

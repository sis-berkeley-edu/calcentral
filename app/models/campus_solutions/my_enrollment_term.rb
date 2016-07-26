module CampusSolutions
  class MyEnrollmentTerm < UserSpecificModel

    include Cache::CachedFeed
    include Cache::JsonifiedFeed
    include Cache::UserCacheExpiry
    include Cache::RelatedCacheKeyTracker
    include EnrollmentCardFeatureFlagged

    attr_accessor :term_id

    def get_feed_internal
      return {} unless is_feature_enabled && HubEdos::UserAttributes.new(user_id: @uid).has_role?(:student)
      self.term_id ||= MyEnrollmentTerms.new(@uid).default_term_id
      CampusSolutions::EnrollmentTerm.new(user_id: @uid, term_id: term_id).get
    end

    def instance_key
      "#{@uid}-#{term_id}"
    end

  end
end

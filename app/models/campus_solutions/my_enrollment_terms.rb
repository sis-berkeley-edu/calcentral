module CampusSolutions
  class MyEnrollmentTerms < UserSpecificModel
    include Cache::CachedFeed
    include Cache::UserCacheExpiry

    def self.get_terms(uid)
      if response = self.new(uid).get_feed
        Array.wrap(response.try(:[], :feed).try(:[], :enrollmentTerms)).sort_by { |term| term.try(:[], :termId) }
      end
    end

    def get_feed_internal
      CampusSolutions::EnrollmentTerms.new({user_id: @uid}).get
    end
  end
end

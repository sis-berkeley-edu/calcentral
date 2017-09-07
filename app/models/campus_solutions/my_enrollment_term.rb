module CampusSolutions
  class MyEnrollmentTerm < UserSpecificModel
    include Cache::CachedFeed
    include Cache::UserCacheExpiry
    include Cache::RelatedCacheKeyTracker

    def self.get_term(uid, term_id)
      if response = self.new(uid, {term_id: term_id}).get_feed
        response.try(:[], :feed).try(:[], :enrollmentTerm)
      end
    end

    def get_feed_internal
      CampusSolutions::EnrollmentTerm.new({user_id: @uid, term_id: @options[:term_id]}).get
    end

    def instance_key
      "#{@uid}-#{@options[:term_id]}"
    end

  end
end

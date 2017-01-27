module HubEnrollments
  class MyTermEnrollments < UserSpecificModel
    include Cache::CachedFeed
    include Cache::FeedExceptionsHandled
    include Cache::UserCacheExpiry

    def initialize (options = {})
      @uid = options[:user_id]
      @term_id = options[:term_id]
    end

    def get_feed_internal
      term_enrollments = HubEnrollments::TermEnrollments.new(user_id: @uid, term_id: @term_id).get
      if (enrollments = term_enrollments.try(:[], :feed))
        logger.warn("Maximum enrollment size of #{enrollments.length} from Enrollments API reached, additional enrollments not being shown for UID #{@uid}") if enrollments.length == 50
      end
      term_enrollments
    end

  end
end

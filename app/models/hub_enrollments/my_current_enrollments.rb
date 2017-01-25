module HubEnrollments
  class MyCurrentEnrollments < UserSpecificModel
    include Cache::CachedFeed
    include Cache::FeedExceptionsHandled
    include Cache::UserCacheExpiry
    include Cache::JsonifiedFeed

    def initialize (options = {})
      @uid = options[:user_id]
      @term_id = options[:term_id]
    end

    def get_feed_internal
      current_enrollments = HubEnrollments::CurrentEnrollments.new(user_id: @uid, term_id: @term_id).get
      if (enrollments = current_enrollments.try(:[], :feed))
        logger.warn("Maximum enrollment size of #{enrollments.length} from Enrollments API reached, additional enrollments not being shown.") if enrollments.length == 50
      end
      current_enrollments
    end

  end
end

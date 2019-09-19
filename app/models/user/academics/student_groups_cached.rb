module User
  module Academics
    class StudentGroupsCached < UserSpecificModel
      include Cache::CachedFeed
      include Cache::UserCacheExpiry

      def initialize(user)
        @user = user
      end

      def get_feed_internal
        rows = Queries.student_groups(@user.campus_solutions_id)
        Rails.logger.debug "[SISRP-48320] #{self.class}#get_feed_internal: #{rows.inspect}"
        rows
      end
    end
  end
end

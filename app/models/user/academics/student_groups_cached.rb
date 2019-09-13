module User
  module Academics
    class StudentGroupsCached < UserSpecificModel
      include Cache::CachedFeed
      include Cache::UserCacheExpiry

      def initialize(user)
        @user = user
      end

      def get_feed_internal
        Queries.student_groups(@user.campus_solutions_id)
      end
    end
  end
end

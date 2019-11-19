module User
  module Academics
    module TermPlans
      class TermPlansCached < UserSpecificModel
        include Cache::CachedFeed
        include Cache::UserCacheExpiry

        attr_reader :user, :uid

        def initialize(user)
          @user = user
          @uid = user.uid
        end

        def get_feed_internal
          Queries.get_student_term_cpp(user.campus_solutions_id)
        end
      end
    end
  end
end

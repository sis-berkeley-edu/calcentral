module User
  module Academics
    module DegreeProgress
      module Graduate
        class CandidacyTermStatusesCached < UserSpecificModel
          include Cache::CachedFeed
          include Cache::UserCacheExpiry

          def initialize(user)
            @user = user
            @uid = user.uid
          end

          def get_feed_internal
            User::Academics::DegreeProgress::Queries.candidacy_term_status(@user.campus_solutions_id)
          end
        end
      end
    end
  end
end

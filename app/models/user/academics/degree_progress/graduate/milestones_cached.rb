module User
  module Academics
    module DegreeProgress
      module Graduate
        class MilestonesCached < UserSpecificModel
          include Cache::CachedFeed
          include Cache::UserCacheExpiry

          def initialize(user)
            @user = user
            @uid = user.uid
          end

          def get_feed_internal
            response = CampusSolutions::DegreeProgress::GraduateMilestones.new(user_id: @uid).get
            return [] if response[:errored] || response[:noStudentId]
            response.try(:[], :feed).try(:[], :ucAaProgress).try(:[], :progresses) || []
          end
        end
      end
    end
  end
end

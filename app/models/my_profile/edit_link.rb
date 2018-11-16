module MyProfile
  class EditLink < UserSpecificModel
    include Cache::CachedFeed
    include Cache::UserCacheExpiry
    include LinkFetcher

    def get_feed_internal
      {
        feed: {
          editProfile: edit_profile_link
        },
        statusCode: 200
      }
    end

    private

    def edit_profile_link
      fetch_link('UC_CX_PROFILE', {EMPLID: campus_solutions_id.to_s}) if can_edit_profile?
    end

    def can_edit_profile?
      roles = User::AggregatedAttributes.new(@uid).get_feed.try(:[], :roles)
      roles.try(:[], :student) || roles.try(:[], :applicant) || roles.try(:[], :releasedAdmit)   || roles.try(:[], :exStudent)
    end

    def campus_solutions_id
      CalnetCrosswalk::ByUid.new(user_id: @uid).lookup_campus_solutions_id
    end
  end
end

module DegreeProgress
  class MyGraduateMilestones < UserSpecificModel
    # This model provides a student-specific version of milestone data for GRAD and LAW career.

    include Cache::CachedFeed
    include Cache::JsonifiedFeed
    include Cache::UserCacheExpiry
    include MilestonesModule

    LINKS_CONFIG = [
      { feed_key: :advancement_form_submit, cs_link_key: 'UC_CX_GT_AAQEAPPLIC_ADD' },
      { feed_key: :advancement_form_view, cs_link_key: 'UC_CX_GT_AAQEAPPLIC_VIEW' }
    ]

    def get_feed_internal
      return {} unless is_feature_enabled? && target_audience?
      response = CampusSolutions::DegreeProgress::GraduateMilestones.new(user_id: @uid).get
      response[:feed] = HashConverter.camelize({
        degree_progress: process(response),
        links: get_links
      })
      response
    end

    def get_links
      links = {}
      LINKS_CONFIG.each do |setting|
        link = fetch_link setting[:cs_link_key]
        links[setting[:feed_key]] = link unless link.blank?
      end
      links
    end

    def fetch_link(link_key)
      if (link_feed = CampusSolutions::Link.new.get_url link_key)
        link = link_feed.try(:[], :link)
      end
      logger.error "Could not retrieve CS link #{link_key} for Degree Progress feed, uid = #{@uid}" unless link
      link
    end

    private

    def target_audience?
      User::SearchUsersByUid.new(id: @uid, roles: [:graduate, :law]).search_users_by_uid.present?
    end

    def is_feature_enabled?
      Settings.features.cs_degree_progress_grad_student
    end
  end
end

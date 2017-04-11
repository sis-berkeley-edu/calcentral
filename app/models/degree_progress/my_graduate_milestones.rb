module DegreeProgress
  class MyGraduateMilestones < UserSpecificModel
    # This model provides a student-specific version of milestone data for GRAD and LAW career.

    include Cache::CachedFeed
    include Cache::JsonifiedFeed
    include Cache::UserCacheExpiry
    include MilestonesModule
    include LinkFetcher

    LINKS_CONFIG = [
      { feed_key: :apply_for_advancement_to_candidacy, cs_link_key: 'UC_CX_GT_GRAD_ADVC' },
      { feed_key: :apply_doctors_qualifying_exam, cs_link_key: 'UC_CX_GT_GRAD_APPQE' },
      { feed_key: :submit_doctoral_degree_candidacy_review, cs_link_key: 'UC_CX_GT_SRDCR_ADD_DP' },
      { feed_key: :view_submitted_forms, cs_link_key: 'UC_CX_GT_STUDENT_VIEW_DP' }
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

    private

    def target_audience?
      User::SearchUsersByUid.new(id: @uid, roles: [:graduate, :law, :exStudent]).search_users_by_uid.present?
    end

    def is_feature_enabled?
      Settings.features.cs_degree_progress_grad_student
    end
  end
end

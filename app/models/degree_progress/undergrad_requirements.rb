module DegreeProgress
  class UndergradRequirements < UserSpecificModel
    # This model provides an advisor-specific version of milestone data for UGRD career.

    include Cache::CachedFeed
    include Cache::JsonifiedFeed
    include Cache::UserCacheExpiry
    include RequirementsModule

    LINKS_CONFIG = [
      { feed_key: :academic_progress_report, cs_link_key: 'UC_CX_APR_RPT_STDNT' }
    ]

    def get_feed_internal
      return {} unless is_feature_enabled?
      response = CampusSolutions::DegreeProgress::UndergradRequirements.new(user_id: @uid).get
      if response[:errored] || response[:noStudentId]
        response[:feed] = {}
      else
        response[:feed] = HashConverter.camelize({
          degree_progress: process(response),
          links: get_links
        })
      end
      response
    end

    private

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
      logger.error "Could not retrieve CS link #{link_key} for #{self.class.name} feed, uid = #{@uid}" unless link
      link
    end

    def is_feature_enabled?
      Settings.features.cs_degree_progress_ugrd_advising
    end
  end
end

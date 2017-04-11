module DegreeProgress
  class UndergradRequirements < UserSpecificModel
    # This model provides an advisor-specific version of milestone data for UGRD career.

    include Cache::CachedFeed
    include Cache::JsonifiedFeed
    include Cache::UserCacheExpiry
    include RequirementsModule
    include LinkFetcher

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

    def student_empl_id
      CalnetCrosswalk::ByUid.new(user_id: @uid).lookup_campus_solutions_id
    end

    def get_links
      links = {}
      links_config = [
        { feed_key: :academic_progress_report, cs_link_key: 'UC_CX_APR_RPT_STDNT', cs_link_params: { :EMPLID => student_empl_id } }
      ]
      links_config.each do |setting|
        link = fetch_link setting[:cs_link_key], setting[:cs_link_params]
        links[setting[:feed_key]] = link unless link.blank?
      end
      links
    end

    def is_feature_enabled?
      Settings.features.cs_degree_progress_ugrd_advising
    end
  end
end

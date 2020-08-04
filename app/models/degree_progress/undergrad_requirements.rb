module DegreeProgress
  class UndergradRequirements < UserSpecificModel
    # This model provides an advisor-specific version of milestone data for UGRD career.
    include Cache::CachedFeed
    include Cache::JsonifiedFeed
    include Cache::UserCacheExpiry
    include RequirementsModule

    APR_LINK_ID = 'UC_CX_APR_RPT_STDNT'
    WHAT_IF_APR_LINK_ID = 'UC_CX_WHIF_RPT'

    def get_feed_internal
      return {} unless is_feature_enabled?
      response = CampusSolutions::DegreeProgress::UndergradRequirements.new(user_id: @uid).get
      if response[:errored] || response[:noStudentId]
        response[:feed] = {}
      else
        response[:feed] = HashConverter.camelize({
          degree_progress: process(response),
          links: links
        })
      end
      response
    end

    def links
      Hash.new.tap do |hash|
        hash[:academic_progress_report] = fetch_link(APR_LINK_ID, { :EMPLID => student_empl_id })
        hash[:academic_progress_report_faqs] = fetch_link(APR_FAQS_LINK_ID)
        hash[:academic_progress_report_what_if] = fetch_link(WHAT_IF_APR_LINK_ID)
      end
    end

    def is_feature_enabled?
      Settings.features.cs_degree_progress_ugrd_advising
    end
  end
end

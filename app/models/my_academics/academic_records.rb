module MyAcademics
  class AcademicRecords < UserSpecificModel
    include Cache::CachedFeed
    include Cache::UserCacheExpiry
    include LinkFetcher

    def get_feed_internal
      {
        officialTranscriptRequestData: get_official_transcript_request_data,
        lawUnofficialTranscriptLink: law_unofficial_transcript_link,
        academicRoles: HubEdos::MyAcademicStatus.get_roles(@uid),
      }
    end

    def get_official_transcript_request_data
      cs_official_transcript = CampusSolutions::CsOfficialTranscript.new(user_id: @uid).get
      return {errored: true} if (cs_official_transcript[:statusCode] != 200)
      filtered_keys = [:debugDbname, :debugJavaString1, :debugJavaString2]
      transcript_data = cs_official_transcript.try(:[], :feed).try(:[], :transcriptOrder)
      transcript_post_url = transcript_data.delete(:credSolLink).to_s.strip
      transcript_post_params = transcript_data.except(*filtered_keys)
      {
        postUrl: transcript_post_url,
        postParams: transcript_post_params
      }
    end

    def law_unofficial_transcript_link
      fetch_link('UC_CX_RQST_UNOFF_LAW_TRANSCRPT', {EMPLID: campus_solutions_id.to_s})
    end

    def campus_solutions_id
      campus_solutions_id = CalnetCrosswalk::ByUid.new(user_id: @uid).lookup_campus_solutions_id
    end
  end
end

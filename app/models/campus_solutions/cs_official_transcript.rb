module CampusSolutions
  class CsOfficialTranscript < CachedProxy

    include CampusSolutionsIdRequired

    def url
      "#{@settings.base_url}/UC_SR_TRNSCPT_DATA.v1/Get?EMPLID=#{@campus_solutions_id}"
    end

    def xml_filename
      'cs_official_transcript.xml'
    end
  end
end

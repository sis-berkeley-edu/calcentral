module CampusSolutions
  class CeDiplomaSso < Proxy

    include CampusSolutionsIdRequired

    def initialize(options = {})
      super options
      initialize_mocks if @fake
    end

    def xml_filename
      'ce_diploma_sso.xml'
    end

    def url
      "#{@settings.base_url}/UC_SR_CEDIPLOMA_URL.v1/emplid=#{@campus_solutions_id}"
    end
  end
end

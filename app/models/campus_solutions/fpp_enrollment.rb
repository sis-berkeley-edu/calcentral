module CampusSolutions
  class FppEnrollment < GlobalCachedProxy

    include CampusSolutions::Billing::BillingFeatureFlagged

    def initialize(options = {})
      super options
      initialize_mocks if @fake
    end

    def xml_filename
      'fpp_enrollment.xml'
    end

    def build_feed(response)
      return {} if response.parsed_response.blank?
      response.parsed_response
    end

    def url
      "#{@settings.base_url}/UC_SF_FPP_LINKS_GET.v1/Get"
    end

  end
end

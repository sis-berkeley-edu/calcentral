module CampusSolutions
  class HigherOneUrl < Proxy

    include Sir::SirFeatureFlagged
    include CampusSolutionsIdRequired

    def initialize(options = {})
      super(options)
      @delegate_uid = options[:delegate_uid]
      initialize_mocks if @fake
    end

    def xml_filename
      'higher_one_url.xml'
    end

    def build_feed(response)
      return {} if response.parsed_response.blank?
      response.parsed_response
    end

    def build_url
      response = self.get
      [:feed, :root, :higherOneUrl, :url].inject(response) { |hash, key| hash[key] if hash }
    end

    def url
      query_args = @delegate_uid ? "DELEGATE_UID=#{@delegate_uid}&EMPLID=#{@campus_solutions_id}" : "EMPLID=#{@campus_solutions_id}"
      "#{@settings.base_url}/UC_OB_HIGHER_ONE_URL_GET.v1/get?#{query_args}"
    end

  end
end

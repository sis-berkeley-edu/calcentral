module HubEnrollments
  class TermEnrollments < Proxy

    def initialize (options = {})
      @term_id = options[:term_id]
      super(options)
    end

    def json_filename
      'hub_term_enrollments.json'
    end

    # Returns only the passed term's enrollments in primary class sections.  This response is limited to 50
    # enrollments.  If more is needed, a loop will be required.
    def url
      "#{@settings.base_url}/#{@campus_solutions_id}?term-id=#{@term_id}&primary-only=true&page-size=50"
    end

    def wrapper_keys
      %w(apiResponse response studentEnrollments)
    end

  end
end

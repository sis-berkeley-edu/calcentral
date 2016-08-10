module HubEdos
  class Demographics < Student

    def initialize(options = {})
      super(options)
      @include_fields = options[:include_fields] || %w(ethnicities languages usaCountry foreignCountries birth gender residency)
      @instance_key = Cache::KeyGenerator.per_view_as_type @uid, options
    end

    def url
      "#{@settings.base_url}/#{@campus_solutions_id}/demographic"
    end

    def json_filename
      'hub_demographics.json'
    end

    def include_fields
      @include_fields
    end

    def instance_key
      @instance_key
    end

    def build_feed(response)
      response = super(response)
      return response if response['student'].blank?
      residency = response['student']['residency']
      return response if residency.blank? || residency['fromTerm'].blank?

      # Add residency.fromTerm.label to the response
      residency['fromTerm']['label'] = Berkeley::TermCodes.normalized_english(residency['fromTerm']['name'])

      # Add residency.message.code to the response
      slr_status = get_residency_item(residency['statementOfLegalResidenceStatus'])
      residency_status = get_residency_item(residency['official'])
      tuition_exception = get_residency_item(residency['tuitionException'])
      message_code = Berkeley::ResidencyMessageCode.residency_message_code(slr_status, residency_status, tuition_exception)
      residency['message'] = {'code' => message_code}

      response
    end

    def get_residency_item(path)
      return '' if path.blank?
      return path['code'] || ''
    end
  end
end

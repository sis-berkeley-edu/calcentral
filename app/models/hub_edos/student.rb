module HubEdos
  class Student < Proxy

    def initialize(options = {})
      super(options)
      @include_fields = options[:include_fields]
    end

    def url
      "#{@settings.base_url}/#{@campus_solutions_id}/all"
    end

    def json_filename
      'hub_student.json'
    end

    def build_feed(response)
      transformed_response = filter_fields(transform_address_keys(super(response)), whitelist_fields)
      {
        'student' => transformed_response
      }
    end

    def empty_feed
      {
        'student' => {}
      }
    end

    def transform_address_keys(student)
      if student['addresses'].present?
        student['addresses'].each do |address|
          address['state'] = address.delete('stateCode')
          address['postal'] = address.delete('postalCode')
          address['country'] = address.delete('countryCode')
        end
      end
      student
    end

    def filter_fields(student, whitelisted_fields)
      return student if whitelisted_fields.nil?
      result = {}
      student.keys.each do |field|
        result[field] = student[field] if whitelisted_fields.include? field
      end
      result
    end

    # Restrict output to these fields to avoid caching and transferring unused portions of the upstream feed.
    def whitelist_fields
      nil
    end

    def unwrap_response(response)
      students = super(response)
      students.any? ? students[0] : {}
    end

    def wrapper_keys
      %w(apiResponse response any students)
    end

    def process_response_after_caching(response)
      response = super(response)
      if @include_fields.present? && (fields_root = response.try(:[], :feed).try(:[], 'student')).present?
        response[:feed]['student'] = filter_fields(fields_root, @include_fields)
      end
      response
    end

  end
end

module HubEdos
  module V1
    class Student < Proxy

      def initialize(options = {})
        super(options)
        @include_fields = options[:include_fields]
      end

      def url
        "#{@settings.base_url}/v1/students/#{@campus_solutions_id}/all"
      end

      def json_filename
        'hub_student.json'
      end

      def build_feed(response)
        address_transformed_response = HubEdos::SharedHelpers.transform_address_keys(super(response))
        transformed_response = HubEdos::SharedHelpers.filter_fields(address_transformed_response, whitelist_fields)
        {
          'student' => transformed_response
        }
      end

      def empty_feed
        {
          'student' => {}
        }
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
          response[:feed]['student'] = HubEdos::SharedHelpers.filter_fields(fields_root, @include_fields)
        end
        response
      end

    end
  end
end

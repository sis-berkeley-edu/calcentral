module HubEdos
  module StudentApi
    module V2
      class Proxy < ::HubEdos::Proxy

        def initialize(options = {})
          super(options)
          @include_fields = options[:include_fields]
        end

        def build_feed(response)
          filter_fields(super(response), whitelist_fields)
        end

        # Restrict output to these fields to avoid caching and transferring unused portions of the upstream feed.
        def whitelist_fields
          nil
        end

        def wrapper_keys
          %w(apiResponse response)
        end

        def process_response_after_caching(response)
          response = super(response)
          if @include_fields.present? && (fields_root = response.try(:[], :feed).try(:[], 'student')).present?
            response[:feed]['student'] = filter_fields(fields_root, @include_fields)
          end
          response
        end

        def filter_fields(input_hash, whitelisted_fields = nil)
          return input_hash if whitelisted_fields.blank?
          input_hash.slice(*whitelisted_fields)
        end

      end
    end
  end
end

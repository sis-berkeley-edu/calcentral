module HubEdos
  module ResponseHandler

    def unwrap_response(response)
      raise Errors::ApiContractError, "Invalid response received from #{url}" unless response.is_a? Hash
      unwrapped = wrapper_keys.inject(response) do |feed, key|
        unless feed.is_a?(Hash) && feed.has_key?(key)
          raise Errors::ApiContractError, "'#{key}' node not found in request to #{url}"
        end
        feed[key]
      end
      if unwrapped.respond_to?(:each)
        return unwrapped
      else
        raise Errors::ApiContractError, "Unwrapped response from #{url} is an invalid type"
      end
    end

    # Now reflecting Student API v2 default wrapper
    def wrapper_keys
      %w(apiResponse response)
    end
  end
end

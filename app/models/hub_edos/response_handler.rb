module HubEdos
  module ResponseHandler

    def unwrap_response(response)
      return [] unless response.is_a? Hash
      unwrapped = wrapper_keys.inject(response) { |feed, key| (feed.is_a?(Hash) && feed[key]) || [] }
      unwrapped.respond_to?(:each) ? unwrapped : []
    end

    def wrapper_keys
      %w(apiResponse response any)
    end

  end
end

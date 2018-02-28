module CampusSolutions
  class SirResponseController < CampusSolutionsController
    rescue_from Errors::ClientError, with: :handle_client_error

    before_filter :exclude_acting_as_users

    def post
      post_passthrough CampusSolutions::Sir::MySirResponse
    end

  end
end

module GoogleApps
  module Auth
    # Token Storage class used by Google Auth Library
    # See https://github.com/googleapis/google-auth-library-ruby#storage
    class TokenStore

      # Load the token data from storage for the given ID.
      #
      # @param [String] id
      #  ID of token data to load.
      # @return [String]
      #  The loaded token data in JSON string format.
      def load(user_id)
        if user_oauth_data = User::Oauth2Data.get(user_id)
          token_data = {
            client_id: Settings.google_proxy.client_id,
            scope: Settings.google_proxy.scope,
            access_token: user_oauth_data[:access_token],
            refresh_token: user_oauth_data[:refresh_token],
            expiration_time_millis: user_oauth_data[:expiration_time].to_i * 1000,
          }
          return token_data.to_json
        end
      end

      # Put the token data into storage for the given ID.
      #
      # @param [String] id
      #  ID of token data to store.
      # @param [String] token
      #  The token data to store.
      def store(user_id, token_data_string)
        Rails.logger.debug "Storing token data: user_id: #{user_id}"
        token_data = MultiJson.load token_data_string
        access_token = token_data['access_token']
        refresh_token = token_data['refresh_token']
        expiration_time = token_data['expiration_time_millis'].to_i / 1000
        options = {
          app_data: {
            client_id: token_data['client_id'],
            scope: token_data['scope'],
          }
        }
        User::Oauth2Data.new_or_update(user_id, access_token, refresh_token, expiration_time, options)
      end

      # Remove the token data from storage for the given ID.
      #
      # @param [String] id
      #  ID of the token data to delete
      def delete(user_id)
        User::Oauth2Data.remove(user_id)
      end
    end
  end
end

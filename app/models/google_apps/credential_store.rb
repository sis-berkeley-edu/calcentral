module GoogleApps
  class CredentialStore
    include ClassLogger

    def initialize(app_id, uid, opts={})
      raise ArgumentError, 'Credential store lookup requires both app_id and user_id' if app_id.blank? || uid.blank?
      @app_id = app_id
      @uid = uid
      @opts = opts || {}
    end

    # Do not change the signature of this method because it is invoked by Google::APIClient
    def load_credentials
      oauth2_data = User::Oauth2Data.get(@uid, @app_id)
      return nil if oauth2_data.empty?
      credentials = CredentialStore.settings_of @app_id
      credentials.merge! oauth2_data
      # Infer times
      unless credentials[:expires_in] && credentials[:issued_at]
        credentials[:expires_in] = 3600
        expiration_time = credentials[:expiration_time].to_i
        credentials[:issued_at] = Time.at(expiration_time - 3600)
      end
      credentials
    end

    # Do not change the signature of this method because it is invoked by Google::APIClient
    def write_credentials(auth = nil)
      return nil if auth.nil?
      if auth.is_a? Hash
        logger.debug "OAuth tokens in hash (app_id: #{@app_id}; uid: #{@uid})"
        opts = @opts.merge auth.symbolize_keys
        write(auth[:access_token], auth[:refresh_token], opts)
      elsif auth.is_a?(Signet::OAuth2::Client) && auth.access_token && auth.refresh_token
        logger.debug "OAuth tokens in #{auth.class} (app_id: #{@app_id}; uid: #{@uid})"
        opts = @opts.merge({
          issued_at: auth.issued_at,
          expires_in: auth.expires_in
        })
        write(auth.access_token, auth.refresh_token, opts)
      else
        raise ArgumentError, "Signet::OAuth2 is missing tokens OR we have unsupported type of OAuth2 client auth: #{auth}"
      end
    end

    def write(access_token, refresh_token, opts={})
      raise ArgumentError, 'Both access_token and refresh_token are required in credential store' if access_token.blank? || refresh_token.blank?
      issued_at = opts[:issued_at]
      expires_in = opts[:expires_in]
      unless (expiration_time = opts[:expiration_time])
        insufficient_info = issued_at.blank? || expires_in.blank?
        expiration_time = insufficient_info ? 0 : issued_at.to_i + expires_in.to_i
      end
      User::Oauth2Data.new_or_update(
        @uid,
        @app_id,
        access_token,
        refresh_token,
        expiration_time,
        opts)
    end

    def self.settings_of(app_id)
      return nil unless (settings = Proxy.config_of app_id)
      {
        client_id: settings.client_id,
        client_secret: settings.client_secret,
        scope: settings.scope,
        token_credential_uri: Google::APIClient::Storage::TOKEN_CREDENTIAL_URI,
        authorization_uri: Google::APIClient::Storage::AUTHORIZATION_URI
      }
    end
  end
end

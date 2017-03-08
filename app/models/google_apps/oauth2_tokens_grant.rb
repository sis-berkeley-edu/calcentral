require 'google/api_client'

module GoogleApps
  class Oauth2TokensGrant
    include ClassLogger

    def initialize(user_id, app_id, client_redirect_uri)
      @user_id = user_id
      @app_id = app_id
      @client_redirect_uri = client_redirect_uri
    end

    def refresh_oauth2_tokens_url(params)
      expire
      settings = GoogleApps::CredentialStore.settings_of @app_id
      scope = settings[:scope]
      if (scope_override = params['scope']).present?
        additional_scope = scope_override.is_a?(Array) ? scope_override.join(' ') : scope_override
        scope += " #{additional_scope}"
      end
      opts = {
        scope: scope,
        final_redirect: params['final_redirect'] || '/',
        omit_domain_restriction: params['force_domain'].present? && params['force_domain'] == 'false'
      }
      client = get_client opts
      url = client.authorization_uri(approval_prompt: 'force').to_s
      logger.debug "Initiating OAuth2 authorization for user #{@user_id} via #{url}"
      url
    end

    def process_callback(params, opts={})
      logger.debug "Handling Google authorization callback for user #{@user_id}"
      if params['code'] && params['error'].blank?
        # Clone hash then remove :scope. Google will reject fetch_access_token! if :scope is present.
        modified_opts = opts.clone
        modified_opts.delete :scope
        client = get_client modified_opts
        client.code = params['code']
        client.fetch_access_token!
        logger.warn "Saving #{@app_id} access token for user #{@user_id}"
        credentials = {
          expiration_time: client.expires_in.blank? ? 0 : (client.issued_at.to_i + client.expires_in),
          access_token: client.access_token.to_s,
          refresh_token: client.refresh_token
        }
        store = GoogleApps::CredentialStore.new(@app_id, @user_id, @opts)
        store.write_credentials credentials
        if @app_id == GoogleApps::Proxy::APP_ID
          User::Oauth2Data.update_google_email! @user_id
        end
      else
        logger.warn "Deleting the Google OAuth2 tokens of user #{@user_id} (app_id: #{@app_id}) because callback reported an error: #{params['error']}"
        User::Oauth2Data.remove(@user_id, @app_id)
      end

      expire
    end

    def remove_user_authorization
      logger.warn "Deleting Google OAuth2 tokens of user #{@user_id} (app_id: #{@app_id}) per user request"
      GoogleApps::Revoke.new(user_id: @user_id).revoke
      User::Oauth2Data.remove(@user_id, @app_id)
      expire
    end

    def scope_granted
      return [] unless GoogleApps::Proxy.access_granted?(@user_id, @app_id)
      GoogleApps::Userinfo.new(user_id: @user_id, app_id: @app_id).current_scope
    end

    def expire
      Cache::UserCacheExpiry.notify @user_id
    end

    def get_client(opts={})
      google_client = Google::APIClient.new(options={
        application_name: 'CalCentral',
        application_version: 'v1',
        retries: 3
      })
      client = google_client.authorization
      unless opts[:omit_domain_restriction]
        client.authorization_uri = URI 'https://accounts.google.com/o/oauth2/auth?hd=berkeley.edu'
      end
      settings = GoogleApps::CredentialStore.settings_of @app_id
      client.client_id = settings[:client_id]
      client.client_secret = settings[:client_secret]
      client.redirect_uri = @client_redirect_uri
      final_redirect = opts[:final_redirect] || ''
      client.state = Base64.encode64 final_redirect
      if opts[:scope]
        client.scope = opts[:scope]
        # Do not lose any manually added authorizations when refreshing the more generic list.
        client.update!(
          additional_parameters: {
            'include_granted_scopes' => 'true'
          }
        )
      end
      client
    end

  end
end

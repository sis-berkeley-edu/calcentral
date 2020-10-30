module GoogleApps
  module Auth
    # Provides main interface for Google App Authorization process
    class Authorization
      include ClassLogger

      # Returns authorization object used with Google API requests
      def self.refresh_credential(opts = {})
        # Google::Auth::WebUserAuthorizer#get_credentials requires a 'request' argument
        # so that it can detect and save any updated token data if included with the request.
        # CalCentral shouldn't need to provide the HTTP request object,
        # just to get the 'authorization' object for a Google HTTP API request
        # This assembles such an object similar to the Google::Auth library.
        opts.reverse_merge!({
          access_token: 'fake_access_token',
          refresh_token: 'fake_refresh_token',
          expiration_time: (Cache::CacheableDateTime.new(DateTime.now) + 2.hours).to_i
        })
        Google::Auth::UserRefreshCredentials.new(
          client_id:     Settings.google_proxy.client_id,
          client_secret: Settings.google_proxy.client_secret,
          scope:         Settings.google_proxy.scope,
          access_token:  opts[:access_token],
          refresh_token: opts[:refresh_token],
          expires_at:    opts[:expiration_time]
        )
      end

      def initialize(user_id, request = nil, client_redirect_uri = nil)
        @user_id = user_id
        @request = request
        @client_redirect_uri = client_redirect_uri
      end

      def refresh_authorization_url(params, return_url)
        expire_user_caches
        authorization_url = web_authorizer.get_authorization_url(login_hint: @user_id, request: @request, redirect_to: return_url)
        logger.debug "Initiating OAuth2 authorization for user #{@user_id} via #{authorization_url}"
        return authorization_url
      end

      def process_callback
        credentials_and_target_url = web_authorizer.handle_auth_callback(@user_id, @request)
        User::Oauth2Data.update_google_email! @user_id
        expire_user_caches
        return credentials_and_target_url.to_a[1] || '/'
      end

      # Use to debug 'request' object passed to #process_callback
      def log_relevant_request_data(request)
        # request values
        if request.key?(Google::Auth::WebUserAuthorizer::AUTH_CODE_KEY)
          logger.debug "AUTH_CODE_KEY - request[#{request[Google::Auth::WebUserAuthorizer::AUTH_CODE_KEY]}]: #{request[Google::Auth::WebUserAuthorizer::AUTH_CODE_KEY].inspect}"
        end

        if request.key?(Google::Auth::WebUserAuthorizer::SCOPE_KEY)
          logger.debug "SCOPE_KEY - request[#{request[Google::Auth::WebUserAuthorizer::SCOPE_KEY]}]: #{request[Google::Auth::WebUserAuthorizer::SCOPE_KEY].inspect}"
        end

        if request.key?(Google::Auth::WebUserAuthorizer::ERROR_CODE_KEY)
          logger.debug "ERROR_CODE_KEY - request[#{request[Google::Auth::WebUserAuthorizer::ERROR_CODE_KEY]}]: #{request[Google::Auth::WebUserAuthorizer::ERROR_CODE_KEY].inspect}"
        end

        # request state json values
        if request.key?(Google::Auth::WebUserAuthorizer::STATE_PARAM)
          state = MultiJson.load(request[STATE_PARAM] || '{}')
          logger.debug "request[#{Google::Auth::WebUserAuthorizer::STATE_PARAM}]: #{state.inspect}"

          if state.key?(Google::Auth::WebUserAuthorizer::SESSION_ID_KEY)
            logger.debug "request[#{Google::Auth::WebUserAuthorizer::STATE_PARAM}][#{Google::Auth::WebUserAuthorizer::SESSION_ID_KEY}]: #{state[Google::Auth::WebUserAuthorizer::SESSION_ID_KEY].inspect}"
          end

          if state.key?(Google::Auth::WebUserAuthorizer::CURRENT_URI_KEY)
            logger.debug "request[#{Google::Auth::WebUserAuthorizer::STATE_PARAM}][#{Google::Auth::WebUserAuthorizer::CURRENT_URI_KEY}]: #{state[Google::Auth::WebUserAuthorizer::CURRENT_URI_KEY].inspect}"
          end
        end

        # session values
        if request.session.key?(Google::Auth::WebUserAuthorizer::CALLBACK_STATE_KEY)
          logger.debug "CALLBACK_STATE_KEY - request.session[#{Google::Auth::WebUserAuthorizer::CALLBACK_STATE_KEY}]: #{request.session[Google::Auth::WebUserAuthorizer::CALLBACK_STATE_KEY].inspect}"
        end

        if request.session.key?(Google::Auth::WebUserAuthorizer::XSRF_KEY)
          logger.debug "XSRF_KEY - request.session[#{Google::Auth::WebUserAuthorizer::XSRF_KEY}]: #{request.session[Google::Auth::WebUserAuthorizer::XSRF_KEY].inspect}"
        end
      end

      def remove_user_authorization
        logger.warn "Deleting Google OAuth2 tokens of user #{@user_id} per user request"
        GoogleApps::Revoke.new(user_id: @user_id).revoke
        User::Oauth2Data.remove(@user_id)
        expire_user_caches
      end

      def expire_user_caches
        Cache::UserCacheExpiry.notify @user_id
      end

      def web_authorizer
        client_id = Google::Auth::ClientId.new(Settings.google_proxy.client_id, Settings.google_proxy.client_secret)
        scope = GoogleApps::Proxy.settings.scope
        token_store = GoogleApps::Auth::TokenStore.new
        Google::Auth::WebUserAuthorizer.new(client_id, scope, token_store, '/api/google/handle_callback')
      end

    end
  end
end

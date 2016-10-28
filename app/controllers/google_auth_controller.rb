class GoogleAuthController < ApplicationController

  before_filter :check_google_access
  before_filter :authenticate
  respond_to :json

  def refresh_tokens
    url = google.refresh_oauth2_tokens_url params
    redirect_to url
  end

  def handle_callback
    google.process_callback(params, opts)
    final_redirect = params['state']
    url = final_redirect ? Base64.decode64(final_redirect) : url_for_path('/')
    redirect_to url
  end

  def current_scope
    render json: {
      currentScope: google.scope_granted
    }
  end

  def remove_authorization
    google.remove_user_authorization
    render nothing: true, status: 204
  end

  def dismiss_reminder
    result = false
    unless GoogleApps::Proxy.access_granted? user_id
      result = User::Oauth2Data.dismiss_google_reminder user_id
    end
    User::Api.expire user_id
    render json: {
      result: result
    }
  end

  private

  def google
    @google ||= GoogleApps::Oauth2TokensGrant.new(user_id, app_id, client_redirect_uri)
  end

  def user_id
    session['user_id']
  end

  def app_id
    GoogleApps::Proxy::APP_ID
  end

  def opts
    @opts ||= Settings.google_proxy.marshal_dump
  end

  def client_redirect_uri
    url_for only_path: false, controller: 'google_auth', action: 'handle_callback'
  end

end

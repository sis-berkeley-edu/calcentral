class GoogleAuthController < ApplicationController
  before_action :check_google_access
  before_action :authenticate

  def request_authorization
    return_url = refresh_params[:return_url] || url_for_path('/')
    url = google_authorization.refresh_authorization_url(refresh_params, return_url)
    if url.present?
      redirect_to url
    else
      redirect_to '/'
    end
  end

  def handle_callback
    target_url = google_authorization.process_callback
    redirect_to target_url
  end

  def remove_authorization
    google_authorization.remove_user_authorization
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

  def refresh_params
    params.permit(:return_url)
  end

  def google_authorization
    @google_apps_auth ||= GoogleApps::Auth::Authorization.new(user_id, request, client_redirect_uri)
  end

  def user_id
    session['user_id']
  end

  def opts
    @opts ||= Settings.google_proxy.marshal_dump
  end

  def client_redirect_uri
    url_for only_path: false, controller: 'google_auth', action: 'handle_callback'
  end

end

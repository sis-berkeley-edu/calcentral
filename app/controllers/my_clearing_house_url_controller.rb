class MyClearingHouseUrlController < ApplicationController
  include ClassLogger

  rescue_from Errors::ProxyError, with: :proxy_error

  before_action :allow_inline_scripting_nsc, only: [:redirect]

  def redirect
    response = model_from_session.get_feed_internal
    render html: response.html_safe
  end

  private

  def model_from_session
    options = {}
    ClearingHouse::MyClearingHouseUrl.from_session(session, options)
  end

  def proxy_error(exception)
    logger.debug "Proxy error when attempting to connect with National Student ClearingHouse: #{exception}"
    redirect_to url_for_path '/404'
  end

  def allow_inline_scripting_nsc
    use_secure_headers_override(:enable_unsafe_inline_scripting_nsc)
  end
end

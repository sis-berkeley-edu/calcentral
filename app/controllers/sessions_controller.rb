class SessionsController < ApplicationController
  include ActiveRecordHelper, ClassLogger
  include AllowDelegateViewAs
  include AllowLti

  skip_before_filter :check_reauthentication, :only => [:lookup, :destroy]

  def lookup
    auth = request.env['omniauth.auth']
    logger.info "Omniauth auth hash from SAML = #{auth.inspect}"
    auth_uid = auth['uid']
    logger.info "UID obtained from Omniauth auth hash = #{auth_uid}"

    # Save crosswalk some work by caching critical IDs if they were asserted to us via SAML.
    if auth.respond_to?(:extra)
      logger.warn "Omniauth extra from SAML = #{auth.extra.inspect}"
      cs_id = auth.extra['berkeleyEduCSID']
      sid = auth.extra['berkeleyEduStuID']
      if sid.present? && sid != cs_id
        logger.warn "Conflicting berkeleyEduStuID #{sid} and berkeleyEduCSID #{cs_id} for UID #{auth_uid}"
      end
      if cs_id.present?
        logger.debug "Caching Campus Solutions ID #{cs_id} for UID #{auth_uid} based on SAML assertion"
        User::Identifiers.cache(auth_uid, cs_id)
      end
      if !auth_uid.present? && Settings.cas_use_name_identifier
        auth_uid = auth.extra['nameIdentifier']
        logger.info "nameIdentifier used to obtain UID from Omniauth auth nameIdentifier = #{auth_uid}"
      end
    end

    if params['renew'] == 'true'
      # If we're re-authenticating due to view-as, then the CAS-provided UID should match original_user_id in session.
      if (original_uid = get_original_viewer_uid)
        if original_uid != auth_uid
          logger.warn "User #{original_uid} was view-as on UID #{auth_uid}. Log everyone out. Session message: #{session_message}"
          logout
          return redirect_to Settings.cas_logout_url
        else
          create_reauth_cookie
        end
      elsif session['user_id'] != auth_uid
        # If we're re-authenticating for any other reason, then the CAS-provided UID should
        # match the session "user_id" from the previous authentication.
        logger.warn "RE-AUTHENTICATION: CAS returned UID #{auth_uid} not matching active session: #{session_message}. Starting new session."
        reset_session
      else
        create_reauth_cookie
      end
    else
      if session['lti_authenticated_only'] && session['user_id'] != auth_uid
        logger.warn "LTI SESSION: CAS returned UID #{auth_uid} not matching active session: #{session_message}. Logging user out."
        logout
        return redirect_to Settings.cas_logout_url
      end
      # On normal first-time authentication, start with a clean session. This will have the side-effect
      # of clearing the LTI-authenticated-only flag if the user happened to visit bCourses first.
      reset_session
    end
    continue_login_success auth_uid
  end

  def create_reauth_cookie
    cookies[:reauthenticated] = {:value => true, :expires => 8.hours.from_now}
  end

  def reauth_admin
    redirect_to url_for_path '/auth/cas?renew=true&url=/ccadmin'
  end

  def basic_lookup
    uid = authenticate_with_http_basic do |uid, password|
      uid if password == Settings.developer_auth.password
    end

    if uid
      continue_login_success uid
    else
      failure
    end
  end

  def destroy
    logout
    url = request.protocol + ApplicationController.correct_port(request.host_with_port, request.env['HTTP_REFERER'])

    url = "#{Settings.campus_solutions_proxy.logout_url}&redirect_url=#{CGI.escape url}" if Settings.features.cs_logout
    cas_logout_url = "#{Settings.cas_logout_url}?service=#{CGI.escape url}"

    # CCAdmin uses Delete request route that does not use JS redirect mechanism
    return redirect_to cas_logout_url if request.delete?

    render :json => {
      :redirectUrl => cas_logout_url
    }.to_json
  end

  def failure
    params ||= {}
    params['message'] ||= ''
    redirect_to root_path, :status => 401, :alert => "Authentication error: #{params['message'].humanize}"
  end

  private

  def smart_success_path
    # the :url parameter is returned by the CAS auth server
    (params['url'].present?) ? params['url'] : url_for_path('/dashboard')
  end

  def continue_login_success(uid)
    # Force a new CSRF token to be generated on login.
    # http://homakov.blogspot.com.es/2013/06/cookie-forcing-protection-made-easy.html
    session.try(:delete, :_csrf_token)
    uid = User::AuthenticationValidator.new(uid).validated_user_id
    if (Integer(uid, 10) rescue nil).nil?
      logger.warn "FAILED login with CAS UID: #{uid}"
      redirect_to url_for_path('/uid_error')
    else
      # Unless we're re-authenticating after view-as, initialize the session.
      session['user_id'] = uid unless get_original_viewer_uid
      redirect_to smart_success_path, :notice => 'Signed in!'
    end
  end

  def logout
    begin
      if (uid = session['user_id']) && get_original_viewer_uid
        # TODO: Can we eliminate this cache-expiry in favor of smarter cache-key scheme? E.g., Cache::KeyGenerator
        Cache::UserCacheExpiry.notify uid
        CampusSolutions::DelegateStudentsExpiry.expire uid
      end
      delete_reauth_cookie
      reset_session
    ensure
      ActiveRecord::Base.clear_active_connections!
    end
  end

end

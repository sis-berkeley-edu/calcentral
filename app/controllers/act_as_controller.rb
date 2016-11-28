class ActAsController < ApplicationController
  include ViewAsAuthorization
  include ClassLogger

  skip_before_filter :check_reauthentication, :only => [:stop_act_as]

  def initialize(options = {})
    @act_as_session_key = options[:act_as_session_key] || SessionKey.original_user_id
  end

  def start
    uid_param = params['uid']
    return redirect_to root_path unless valid_params? uid_param
    act_as_authorization uid_param
    logger.warn "Start: #{current_user.real_user_id} act as #{uid_param}"
    session[@act_as_session_key] = session['user_id'] unless session[@act_as_session_key]
    session['user_id'] = User::AuthenticationValidator.new(uid_param).validated_user_id
    # TODO Mimic '/uid_error' redirect for nulled session user IDs.

    # Post-processing
    after_successful_start(session, params)
    render :nothing => true, :status => 204
  end

  def stop
    exiting_uid = session['user_id']
    return redirect_to root_path unless exiting_uid && session[@act_as_session_key]
    # TODO: Can we eliminate the need for this cache-expiry via smarter cache-key scheme? E.g., Cache::KeyGenerator
    Cache::UserCacheExpiry.notify exiting_uid
    logger.warn "Stop: #{session[@act_as_session_key]} act as #{exiting_uid}"
    session['user_id'] = session[@act_as_session_key]
    session[@act_as_session_key] = nil

    after_successful_stop session
    render :nothing => true, :status => 204
  end

  private

  def act_as_authorization(uid_param)
    authorize current_user, :can_view_as?
    # Ensure uid is available to the viewer.
    if fetch_another_users_attributes(uid_param).blank?
      logger.warn "User #{current_user.real_user_id} FAILED to login to #{uid_param}, UID not found"
      raise Pundit::NotAuthorizedError.new "User with UID #{uid_param} not found."
    end
  end

  def after_successful_start(session, params)
    # This makes sure the most recently viewed user is at the top of the list
    original_uid = session[@act_as_session_key]
    uid_to_store = params['uid']
    User::StoredUsers.delete_recent_uid(original_uid, uid_to_store)
    User::StoredUsers.store_recent_uid(original_uid, uid_to_store)
  end

  def after_successful_stop(session)
    # Sub-class might want custom cache management.
  end

  def valid_params?(act_as_uid)
    if act_as_uid.blank?
      logger.warn "User #{current_user.real_user_id} FAILED to login to #{act_as_uid}, cannot be blank!"
      return false
    end

    # Ensure that uids are numeric
    begin
      Integer(act_as_uid, 10)
    rescue ArgumentError
      logger.warn "User #{current_user.user_id} FAILED to login to #{act_as_uid}, values must be integers"
      return false
    end

    # Block acting as oneself, because that's way too confusing.
    if act_as_uid.to_i == current_user.real_user_id.to_i
      logger.warn "User #{current_user.user_id} FAILED to login to #{act_as_uid}, cannot view-as oneself"
      raise Pundit::NotAuthorizedError.new "You cannot View as your own ID."
    end

    true
  end

end

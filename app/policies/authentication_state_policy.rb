class AuthenticationStatePolicy
  attr_reader :user, :record

  # This Pundit policy class handles authorization decisions which depend solely upon the current user's
  # authentication state, equivalent to ApplicationController's "current_user". It should be used as the
  # superclass for all other Pundit policies.
  #
  # By design, it ignores the "@record" initialization parameter so that it can be reserved for use by
  # more specific Policy subclasses.
  def initialize(authentication_state, record)
    # Pundit convention is to store the current_user parameter in an instance variable named "@user".
    @user = authentication_state
    @record = record
  end

  def access_google?
    @user.directly_authenticated?
  end

  def can_administrate?
    @user.real_user_auth.active? && @user.real_user_auth.is_superuser? &&
      @user.user_auth.active? && @user.user_auth.is_superuser?
  end

  def can_administrate_canvas?
    can_administrate? || Canvas::Admins.new.admin_user?(@user.user_id)
  end

  def can_administer_oec?
    @user.directly_authenticated? && (can_administrate? || Oec::Administrator.is_admin?(@user.user_id))
  end

  def can_author?
    @user.real_user_auth.active? && (@user.real_user_auth.is_superuser? || @user.real_user_auth.is_author?)
  end

  def can_clear_campus_links_cache?
    can_clear_cache? || can_author?
  end

  def can_clear_cache?
    # Only super-users are allowed to clear caches in production, but in development mode, anyone can.
    !Rails.env.production? || can_administrate?
  end

  def can_reload_yaml_settings?
    !Rails.env.production? || can_administrate?
  end

  def can_create_canvas_project_site?
    return true if can_administrate_canvas?
    attributes = User::AggregatedAttributes.new(@user.user_id).get_feed
    !!(attributes[:roles] && (attributes[:roles][:faculty] || attributes[:roles][:staff]))
  end

  def can_create_canvas_course_site?
    can_administrate_canvas? || can_add_current_official_sections?
  end

  def can_add_current_official_sections?
    Canvas::CurrentTeacher.new(@user.user_id).user_currently_teaching?
  end

  def can_view_as?
    real_auth = @user.real_user_auth
    return false unless real_auth.active?
    real_auth.is_superuser? || real_auth.is_viewer?
  end

  def can_view_confidential?
    @user.real_user_auth.is_superuser? && @user.real_user_auth.active?
  end

  def can_view_webcast_sign_up?
    # Remove feature-flag when Webcast sign-up is supported on CalCentral
    feature_flag = Settings.features.webcast_sign_up_on_calcentral
    feature_flag.present? && feature_flag && (can_administrate? || can_view_as? || can_add_current_official_sections?)
  end

  def can_view_other_user_photo?
    real_auth = @user.real_user_auth
    if real_auth.is_superuser? && real_auth.active?
      true
    else
      User::SearchUsersByUid.new(id: @user.user_id, roles: [:advisor]).search_users_by_uid.present?
    end
  end
end

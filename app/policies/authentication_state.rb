class AuthenticationState
  attr_reader :user_id, :original_user_id, :original_advisor_user_id, :original_delegate_user_id, :canvas_masquerading_user_id, :lti_authenticated_only

  LTI_AUTHENTICATED_ONLY = 'Authenticated through LTI'

  def initialize(session)
    @user_id = session['user_id']
    @original_user_id = session[SessionKey.original_user_id]
    @original_advisor_user_id = session[SessionKey.original_advisor_user_id]
    @original_delegate_user_id = session[SessionKey.original_delegate_user_id]
    @canvas_masquerading_user_id = session['canvas_masquerading_user_id']
    @lti_authenticated_only = session['lti_authenticated_only']
  end

  def classic_viewing_as?
    @original_user_id.present? && (@original_user_id != @user_id)
  end

  def authenticated_as_delegate?
    @original_delegate_user_id.present?
  end

  def delegated_privileges
    @delegated_privileges ||= get_delegated_privileges
  end

  def authenticated_as_advisor?
    @original_advisor_user_id.present?
  end

  def directly_authenticated?
    user_id && !lti_authenticated_only &&
      (original_advisor_user_id.blank? || (user_id == original_advisor_user_id)) &&
      (original_delegate_user_id.blank? || (user_id == original_delegate_user_id)) &&
      (original_user_id.blank? || (user_id == original_user_id))
  end

  def original_user_auth
    @original_user_auth ||= User::Auth.get original_user_id
    # If the previous line resulted in nil then we look for other view-as types
    @original_user_auth ||= User::Auth.get original_advisor_user_id
    @original_user_auth ||= User::Auth.get original_delegate_user_id
  end

  def policy
    @policy ||= AuthenticationStatePolicy.new(self, self)
  end

  def real_user_auth
    if (original_user_id || original_advisor_user_id || original_delegate_user_id) && user_id
      return original_user_auth
    elsif lti_authenticated_only
      # Public permissions only.
      return User::Auth.get(nil)
    else
      return user_auth
    end
  end

  def real_user_id
    if user_id.present?
      if original_user_id.present?
        return original_user_id
      elsif original_advisor_user_id.present?
        return original_advisor_user_id
      elsif original_delegate_user_id.present?
        return original_delegate_user_id
      elsif canvas_masquerading_user_id.present?
        return "#{LTI_AUTHENTICATED_ONLY}: masquerading Canvas ID #{canvas_masquerading_user_id}"
      elsif lti_authenticated_only
        return LTI_AUTHENTICATED_ONLY
      else
        return user_id
      end
    else
      return nil
    end
  end

  # For better exception messages.
  def to_s
    session_props = %w(user_id original_user_id original_advisor_user_id original_delegate_user_id canvas_masquerading_user_id lti_authenticated_only).map do |prop|
      if (prop_value = self.send prop.to_sym)
        "#{prop}=#{prop_value}"
      end
    end
    "#{super.to_s} #{session_props.compact.join(', ')}"
  end

  def user_auth
    @user_auth ||= User::Auth.get(user_id)
  end

  def viewing_as?
    # Return true if either of the two view_as modes is active
    original_uid = original_user_id || original_advisor_user_id || original_delegate_user_id
    original_uid.present? && user_id.present? && (original_uid != user_id)
  end

  def delegation_privileges_for(target_uid)
    acting_user_id = real_user_id
    response = CampusSolutions::DelegateStudents.new(user_id: acting_user_id).get
    if response[:feed] && (students = response[:feed][:students])
      if (student = students.detect { |s| target_uid == s[:uid] }) && student[:privileges].present?
        student[:privileges].select {|privilege, value| value}
      else
        {}
      end
    else
      {}
    end
  end

  private

  def get_delegated_privileges
    return {} unless authenticated_as_delegate?
    delegation_privileges_for user_id
  end

end

class AdvisorActAsController < ActAsController
  include AdvisorAuthorization

  skip_before_filter :check_reauthentication, :only => [:stop_advisor_act_as]

  def initialize
    super act_as_session_key: SessionKey.original_advisor_user_id
  end

  def act_as_authorization(uid_param)
    authorize_advisor_access_to_student current_user.real_user_id, uid_param
  end
end

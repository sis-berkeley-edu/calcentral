class DelegateActAsController < ActAsController
  include AllowDelegateViewAs

  def initialize
    super act_as_session_key: SessionKey.original_delegate_user_id
  end

  def act_as_authorization(uid_param)
    acting_user_id = current_user.real_user_id
    # Expire cache prior to view-as session to guarantee most up-to-date privileges.
    CampusSolutions::DelegateStudentsExpiry.expire acting_user_id
    privileges = current_user.delegation_privileges_for uid_param
    if privileges.present?
      logger.warn "User #{acting_user_id} is authorized to delegate-view-as #{uid_param} with privileges: #{privileges}"
    else
      raise Pundit::NotAuthorizedError.new("User #{acting_user_id} is unauthorized to delegate-view-as student UID #{uid_param}")
    end
  end

  def after_successful_start(session, params)
    # Do nothing
  end

  def after_successful_stop(session)
    CampusSolutions::DelegateStudentsExpiry.expire session['user_id']
  end

end

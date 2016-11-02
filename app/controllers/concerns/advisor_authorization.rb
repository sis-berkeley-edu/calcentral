module AdvisorAuthorization

  def authorize_advisor_view_as(uid, student_uid)
    # View As for advisors is intended to be replaced by the Student Overview feature at some point.
    # View As cannot be tested by a superuser viewing-as an advisor, whereas Student Overview can be.
    authorize_advisor_student_overview(uid, student_uid)
  end

  def authorize_advisor_student_overview(uid, student_uid)
    require_advisor uid
    # The current fine-grained implementation of Advisor Student Overview leads to many calls to this authorization check.
    # It therefore needs to pull from a cached feed.
    opts = {
      id: student_uid,
      roles: [:applicant, :student, :exStudent]
    }
    filtered_user = User::SearchUsersByUid.new(opts).search_users_by_uid
    unless filtered_user
      raise Pundit::NotAuthorizedError.new "User with UID #{student_uid} does not appear to be a current, past, or incoming student."
    end
  end

  def require_advisor(uid)
    unless User::SearchUsersByUid.new(id: uid, roles: [:advisor]).search_users_by_uid
      raise Pundit::NotAuthorizedError.new("User (UID: #{uid}) is not an Advisor")
    end
  end

end

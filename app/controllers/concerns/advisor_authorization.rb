module AdvisorAuthorization

  def authorize_advisor_access_to_student(uid, student_uid)
    require_advisor uid
    unless fetch_another_users_attributes(student_uid).present?
      raise Pundit::NotAuthorizedError.new "User with UID #{student_uid} does not appear to be a current, past, or incoming student."
    end
  end

  def require_advisor(uid)
    unless User::SearchUsersByUid.new(id: uid, roles: [:advisor]).search_users_by_uid
      raise Pundit::NotAuthorizedError.new("User (UID: #{uid}) is not an Advisor")
    end
  end

end

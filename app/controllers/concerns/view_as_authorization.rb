module ViewAsAuthorization
  include AdvisorAuthorization

  def render_403(error)
    if error.respond_to? :message
      render json: { :error => error.message }.to_json, :status => 403
    else
      render :nothing => true, :status => 403
    end
  end

  def authorize_query_stored_users(current_user)
    return if current_user.directly_authenticated? && current_user.policy.can_view_as?
    require_advisor current_user.user_id
  end
end

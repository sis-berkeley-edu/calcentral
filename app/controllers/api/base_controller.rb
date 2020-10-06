class Api::BaseController < ApplicationController
  private

  def require_admin
    unless current_policy.can_administrate?
      head :unauthorized
    end
  end

  def require_author
    unless current_policy.can_author?
      head :unauthorized
    end
  end

  def current_policy
    AuthenticationState.new(session).policy
  end
end

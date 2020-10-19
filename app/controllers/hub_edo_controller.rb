class HubEdoController < ApplicationController
  include AllowDelegateViewAs
  before_action :api_authenticate_401, :authorize_for_enrollments

  def work_experience
    # Delegates get an empty feed.
    if current_user.authenticated_as_delegate?
      return render json: {filteredForDelegate: true}
    end
    json_proxy_passthrough HubEdos::StudentApi::V2::Feeds::WorkExperiences
  end

  def json_proxy_passthrough(classname, options={})
    options = options.merge(user_id: session['user_id'])
    render json: classname.new(options).get
  end

end

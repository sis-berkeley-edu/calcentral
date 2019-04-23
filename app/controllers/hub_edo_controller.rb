class HubEdoController < ApplicationController
  include AllowDelegateViewAs
  before_filter :api_authenticate_401, :authorize_for_enrollments

  def work_experience
    # Delegates get an empty feed.
    if current_user.authenticated_as_delegate?
      return render json: {filteredForDelegate: true}
    end
    json_proxy_passthrough HubEdos::WorkExperience
  end

  def json_passthrough(classname, options={})
    model = classname.from_session session, options
    render json: model.get_feed_as_json
  end

  def json_proxy_passthrough(classname, options={})
    options = options.merge(user_id: session['user_id'])
    render json: classname.new(options).get
  end

end

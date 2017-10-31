class HubEdoController < ApplicationController
  include AllowDelegateViewAs
  before_filter :api_authenticate_401, :authorize_for_enrollments

  def academic_status
    json_passthrough MyAcademics::MyAcademicStatus
  end

  def student
    options = case
                when current_user.authenticated_as_delegate?
                  { include_fields: %w(affiliations identifiers) }
                when current_user.authenticated_as_advisor?
                  { include_fields: %w(addresses affiliations emails emergencyContacts identifiers names phones urls residency gender) }
                else
                  # Rely on the defaults per proxy class
                  {}
              end
    json_passthrough HubEdos::MyStudent, options
  end

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

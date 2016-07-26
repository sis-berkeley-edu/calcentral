class HubEdoController < ApplicationController
  before_filter :api_authenticate_401

  def student
    options = case
                when current_user.authenticated_as_delegate?
                  { include_fields: %w(affiliations identifiers) }
                when current_user.authenticated_as_advisor?
                  { include_fields: %w(addresses affiliations emails emergencyContacts identifiers names phones urls residency) }
                else
                  # Rely on the defaults per proxy class
                  {}
              end
    json_passthrough HubEdos::MyStudent, options
  end

  def work_experience
    # Delegates get an empty feed.
    return {
      'filteredForDelegate' => true
    } if current_user.authenticated_as_delegate?
    json_passthrough HubEdos::MyWorkExperience
  end

  def json_passthrough(classname, options={})
    model = classname.from_session session, options
    render json: model.get_feed_as_json
  end

end

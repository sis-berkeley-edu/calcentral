class MyProfileController < ApplicationController
  include AllowDelegateViewAs
  before_filter :api_authenticate_401, :authorize_for_enrollments

  def get_feed
    options = case
                when current_user.authenticated_as_delegate?
                  { include_fields: %w(affiliations identifiers) }
                when current_user.authenticated_as_advisor?
                  { include_fields: %w(addresses affiliations emails emergencyContacts identifiers names phones urls residency gender) }
                else
                  {}
              end
    render json: HubEdos::MyStudent.from_session(session, options).get_feed_as_json
  end

  def get_edit_link
    render json: MyProfile::EditLink.from_session(session).get_feed_as_json
  end
end

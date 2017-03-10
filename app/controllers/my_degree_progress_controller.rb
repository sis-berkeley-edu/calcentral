class MyDegreeProgressController < ApplicationController
  before_filter :api_authenticate_401
  include AllowDelegateViewAs

  def get_undergraduate_requirements
    render json: ::DegreeProgress::MyUndergradRequirements.from_session(session).get_feed_as_json
  end

  def get_graduate_milestones
    render json: ::DegreeProgress::MyGraduateMilestones.from_session(session).get_feed_as_json
  end
end

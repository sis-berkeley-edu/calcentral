module CampusSolutions
  class DegreeProgressController < CampusSolutionsController
    include AllowDelegateViewAs

    def get
      render json: ::DegreeProgress::MyGraduateMilestones.from_session(session).get_feed_as_json
    end

  end
end

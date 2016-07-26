module CampusSolutions
  class EnrollmentTermsController < CampusSolutionsController
    include AllowDelegateViewAs

    before_filter :authorize_for_enrollments

    def get
      render json: CampusSolutions::MyEnrollmentTerms.from_session(session).get_feed_as_json
    end

  end
end

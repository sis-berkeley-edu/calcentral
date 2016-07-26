module CampusSolutions
  class EnrollmentTermController < CampusSolutionsController
    include AllowDelegateViewAs

    before_filter :authorize_for_enrollments

    def get
      model = CampusSolutions::MyEnrollmentTerm.from_session(session)
      model.term_id = params['term_id']
      render json: model.get_feed_as_json
    end

  end
end

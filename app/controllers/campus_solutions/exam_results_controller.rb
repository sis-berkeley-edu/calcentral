class ExamResultsController < ApplicationController
  before_filter :api_authenticate

  def get_exam_results
    render json: CampusSolutions::ExamResults.from_session(session).get_feed
  end

  def has_exam_results
    render json: CampusSolutions::HasExamResults.from_session(session).get_feed
  end

end

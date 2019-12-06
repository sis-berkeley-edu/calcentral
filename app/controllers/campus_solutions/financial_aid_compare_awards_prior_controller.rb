module CampusSolutions
  class FinancialAidCompareAwardsPriorController < CampusSolutionsController
    include AllowDelegateViewAs

    before_action :authorize_for_financial

    def get
      model = CampusSolutions::MyFinancialAidCompareAwardsPrior.from_session(session)
      model.aid_year = params['aid_year']
      model.date = params['date']
      render json: model.get_feed_as_json
    end

  end
end

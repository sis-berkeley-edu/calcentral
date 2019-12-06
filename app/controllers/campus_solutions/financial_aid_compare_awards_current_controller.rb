module CampusSolutions
  class FinancialAidCompareAwardsCurrentController < CampusSolutionsController
    include AllowDelegateViewAs

    before_action :authorize_for_financial

    def get
      model = CampusSolutions::MyFinancialAidCompareAwardsCurrent.from_session(session)
      model.aid_year = params['aid_year']
      render json: model.get_feed_as_json
    end

  end
end

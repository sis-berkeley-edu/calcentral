module CampusSolutions
  class FinancialAidDataController < CampusSolutionsController
    include AllowDelegateViewAs

    before_action :authorize_for_financial

    def get
      if current_user.authenticated_as_advisor?
        model = CampusSolutions::MyFinancialAidFilteredForAdvisor.from_session session
      elsif current_user.authenticated_as_delegate?
        model = CampusSolutions::MyFinancialAidFilteredForDelegate.from_session session
      else
        model = CampusSolutions::MyFinancialAidData.from_session session
      end
      model.aid_year = params['aid_year']
      render json: model.get_feed_as_json
    end

  end
end

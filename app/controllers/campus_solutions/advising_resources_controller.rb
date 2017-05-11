module CampusSolutions
  class AdvisingResourcesController < CampusSolutionsController
    include AdvisorAuthorization

    before_action :authorize_advisor_access

    def get
      render json: AdvisingResources.generic_links
    end

    private

    def authorize_advisor_access
      require_advisor session['user_id']
    end

  end
end

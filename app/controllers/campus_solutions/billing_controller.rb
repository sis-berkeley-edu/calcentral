module CampusSolutions
  class BillingController < CampusSolutionsController
    include AllowDelegateViewAs

    before_action :authorize_for_financial

    def get_activity
      render json: CampusSolutions::Billing::MyActivity.from_session(session).get_feed_as_json
    end

    def get_links
      render json: CampusSolutions::Billing::Links.new().get
    end

  end
end

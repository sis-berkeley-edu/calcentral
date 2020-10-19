module CampusSolutions
  class HigherOneUrlController < CampusSolutionsController
    include AllowDelegateViewAs
    include DisallowAdvisorViewAs
    include DisallowClassicViewAs
    before_action :authorize_for_financial

    def get
      model = model_from_session
      render json: model.get_feed_as_json
    end

    def redirect
      model = model_from_session
      if (higher_one_url = model.get_higher_one_url)
        redirect_to higher_one_url
      else
        redirect_to url_for_path '/404'
      end
    end

    private

    def model_from_session
      options = {}
      options[:delegate_uid] = current_user.original_delegate_user_id if current_user.authenticated_as_delegate?
      CampusSolutions::MyHigherOneUrl.from_session(session, options)
    end

  end
end

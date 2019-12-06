module CampusSolutions
  class CampusSolutionsController < ApplicationController

    include ClassLogger

    before_action :api_authenticate_401

    def json_passthrough(classname, params={})
      render json: classname.new(params).get
    end

    def post_passthrough(classname)
      model = classname.from_session session
      render json: model.update(request.request_parameters)
    end

    def delete_passthrough(classname)
      model = classname.from_session session
      render json: model.delete(params)
    end

    def exclude_acting_as_users
      return unless Settings.features.prevent_acting_as_users_from_posting
      unless current_user.directly_authenticated?
        logger.warn "ACT-AS: User #{current_user.real_user_id} attempted access to an endpoint which is forbidden while acting-as user #{current_user.user_id}"
        head :forbidden
      end
    end

  end
end

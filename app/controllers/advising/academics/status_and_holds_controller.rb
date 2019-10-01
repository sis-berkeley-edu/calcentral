module Advising
  module Academics
    class StatusAndHoldsController < ApplicationController
      include CampusSolutions::StudentLookupFeatureFlagged
      include AdvisorAuthorization

      before_action :api_authenticate
      before_action :authorize_for_student

      rescue_from StandardError, with: :handle_api_exception
      rescue_from Errors::ClientError, with: :handle_client_error
      rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

      def show
        render json: user.status_and_holds
      end

      def user
        User::Current.new(student_uid)
      end

      def student_uid
        params.require(:id)
      end

      def authorize_for_student
        raise NotAuthorizedError.new('The student lookup feature is disabled') unless is_feature_enabled
        authorize_advisor_access_to_student current_user.user_id, student_uid
      end
    end
  end
end

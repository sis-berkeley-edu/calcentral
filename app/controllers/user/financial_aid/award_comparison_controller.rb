module User
  module FinancialAid
    class AwardComparisonController < ApplicationController
      include AllowDelegateViewAs
      before_action :authorize_for_financial

      def index
        render json: user.award_comparison
      end

      def show
        render json: user.award_comparison_for_aid_year_and_date(params[:aid_year], params[:effective_date])
      end

      private
      def user
        User::Current.new(session['user_id'])
      end
    end
  end
end

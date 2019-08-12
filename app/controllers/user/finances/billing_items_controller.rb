module User
  module Finances
    class BillingItemsController < ApplicationController
      include AllowDelegateViewAs
      before_action :authorize_for_financial

      def index
        render json: billing_items
      end

      def show
        render json: billing_items.find_by_id(params[:id]), include_payments: true
      end

      private

      def billing_items
        user.billing_items
      end

      def user
        User::Current.new(session['user_id'])
      end
    end
  end
end

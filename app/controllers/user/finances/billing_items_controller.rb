module User
  module Finances
    class BillingItemsController < ApplicationController
      include AllowDelegateViewAs
      before_action :authorize_for_financial

      def index
        respond_to do |format|
          format.json do
            render json: billing_items
          end

          format.csv do
            send_data billing_summary.as_csv, {
              type: 'text/csv; charset=utf-8; header=present',
              disposition: "attachment; filename=#{session['user_id']}-billing-summary.csv"
            }
          end
        end
      end

      def show
        render json: billing_items.find_by_id(params[:id]), include_payments: true
      end

      private

      def billing_items
        user.billing_items
      end

      def billing_summary
        user.billing_summary
      end

      def user
        User::Current.new(session['user_id'])
      end
    end
  end
end

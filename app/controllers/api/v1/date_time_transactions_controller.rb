module Api
  module V1
    class DateTimeTransactionsController < ApplicationController
      skip_before_filter :require_login, :require_acceptance_of_terms, :load_portfolio
      respond_to :json

      def create
        @user = User.find_by_id(params[:user_id])
        if @user
          @stock_details = Finance.current_stock_details(params[:stock_id]) or raise ActiveRecord::RecordNotFound
          @date_time_transaction = DateTimeTransaction.new(params[:dtt].merge(user: @user))

          if @date_time_transaction.place!(@stock_details)
            respond_with "Order successfully placed"
          else
            respond_with "Not placed"
          end

        else
          respond_with "Invalid user"
        end
      end

      def destroy
        @user = User.find_by_id(params[:user_id])
        if @user
          @date_time_transaction = DateTimeTransaction.find_by_id(params[:stock_id])
          if @date_time_transaction && @user.id == @date_time_transaction.user_id
            if @date_time_transaction.delete
              respond_with "Order successfully deleted"
            else
              respond_with "Order could not be deleted"
            end
          else
            respond_with "The order you are trying to delete does not exist"
          end
        else
          respond_with "Invalid user"
        end
      end

    end
  end
end

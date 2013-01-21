module Api
  module V1
    class StopLossTransactionsController < ApplicationController
      skip_before_filter :require_login, :require_acceptance_of_terms, :load_portfolio
      respond_to :json

      def create
        @user = User.find_by_id(params[:user_id])
        if @user
          Rails.logger.info params
          @stock_details = Finance.current_stock_details(params[:stock_id]) or raise ActiveRecord::RecordNotFound
          @stop_loss_transaction = StopLossTransaction.new(params[:slt].merge(user: @user))

          if @stop_loss_transaction.place!(@stock_details)
            respond_with "Order successfully placed"
          else
            respond_with "Order could not be placed"
          end
        else
          respond_with "invalid user"
        end

      end

      def destroy
        @user = User.find_by_id(params[:user_id])
        if @user
          @stop_loss_transaction = StopLossTransaction.find_by_id(params[:stock_id])
          if @stop_loss_transaction && @user.id == @stop_loss_transaction.user_id
            if @stop_loss_transaction.delete
              respond_with "Order successfully deleted"
            else
              respond_with "Order could not be deleted"
            end
          else
            respond_with "The order you are trying to delete does not exist"
          end
        else
          respond_with "invalid user"
        end
      end

    end
  end
end


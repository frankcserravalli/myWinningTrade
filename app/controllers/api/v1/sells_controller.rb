module Api
  module V1
    class SellsController < ApplicationController
      skip_before_filter :verify_authenticity_token
      skip_before_filter :require_login, :require_acceptance_of_terms, :load_portfolio
      respond_to :json

      def create
        @user = User.find_by_id(params[:user_id])
        if @user
          @stock_details = Finance.current_stock_details(params[:stock_id]) or raise ActiveRecord::RecordNotFound

          @order = SellTransaction.new(params[:sell].merge(user: @user))

          if @order.place!(@stock_details)
            respond_with "Successfully sold #{@order.volume} shares from #{params[:stock_id]}"
          else
            respond_with "Could not process order"
          end
        else
          respond_with "Invalid user"
        end
      end

    end
  end
end


module Api
  module V1
    class BuysController < ApplicationController
      skip_before_filter :require_login, :require_acceptance_of_terms, :load_portfolio
      respond_to :json

      def create
        @user = User.find_by_id(params[:user_id])
        if @user
          @stock_details = Finance.current_stock_details(params[:stock_id]) or raise ActiveRecord::RecordNotFound
          @buy_order = Buy.new(params[:buy].merge(user: @user))
          if @buy_order.place!(@stock_details)
            respond_with "Successfully purchased #{@buy_order.volume} #{params[:stock_id]} for $#{-@buy_order.value.round(2)} (incl. $6 transaction fee)"
          else
            respond_with "Buy could not be processed"
          end
        else
          respond_with "Invalid user"
        end
      end
    
    end
  end
end


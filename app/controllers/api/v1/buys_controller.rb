module Api
  module V1
    class BuysController < ApplicationController

      skip_before_filter :require_login, :require_acceptance_of_terms, :load_portfolio
      respond_to :json

      def create
        @user = User.find_by_id(params[:user_id])
        if @user
          @stock_details = Finance.current_stock_details(params[:stock_id]) or raise ActiveRecord::RecordNotFound

          # This is used to set the params up on here
          # and save the iOS side from sending params with hashes within hashes
          params[:buy][:volume] = params[:volume]

          @buy_order = Buy.new(params[:buy].merge(user: @user))

          if @buy_order.place!(@stock_details)
            render :json => @buy_order.to_json
          else
            render :json => { }
          end
        else
          render :json => { }
        end
      end
    
    end
  end
end


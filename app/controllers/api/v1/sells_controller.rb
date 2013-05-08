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

          # This is used to set the params up on here
          # and save the iOS side from sending params with hashes within hashes
          params[:sell][:volume] = params[:volume]

          puts params


          @order = SellTransaction.new(params[:sell].merge(user: @user))

          if @order.place!(@stock_details)
            render :json => @order.to_json
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


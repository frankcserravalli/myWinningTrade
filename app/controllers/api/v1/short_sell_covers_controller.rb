module Api
  module V1
    class ShortSellCoversController < ApplicationController
      skip_before_filter :verify_authenticity_token
      skip_before_filter :require_login, :require_acceptance_of_terms, :load_portfolio
      respond_to :json

      def create
        user = User.find(params[:user_id])

        if user
          stock_details = Finance.current_stock_details(params[:stock_id]) or raise ActiveRecord::RecordNotFound

          order = ShortTransaction.new(params[:short_sell_cover].merge(user: user))

          if order.place!(stock_details)
            render :json => { status: "Order placed." }

          else
            render :json => {  }
          end
        else
          render :json => { }
        end
      end

    end
  end
end


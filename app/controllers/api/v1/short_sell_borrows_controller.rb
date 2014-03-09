module Api
  module V1
    class ShortSellBorrowsController < ApplicationController
      skip_before_filter :verify_authenticity_token
      skip_before_filter :require_login, :require_acceptance_of_terms, :load_portfolio

      respond_to :json

      def create
        user = User.find(params[:user_id])

        if user
          stock_details = Finance.current_stock_details(params[:stock_id])

          if stock_details
            # Here we inject the params into a bigger params hash
            params[:short_sell_borrow] = {}
            params[:short_sell_borrow][:volume] = params[:volume]
            params[:short_sell_borrow][:when] = params[:when]
            params[:short_sell_borrow]["execute_at(1i)"] = params["execute_at(1i)"]
            params[:short_sell_borrow]["execute_at(2i)"] = params["execute_at(2i)"]
            params[:short_sell_borrow]["execute_at(3i)"] = params["execute_at(3i)"]
            params[:short_sell_borrow]["execute_at(4i)"] = params["execute_at(4i)"]
            params[:short_sell_borrow]["execute_at(5i)"] = params["execute_at(5i)"]
            params[:short_sell_borrow][:measure] = params[:measure]
            params[:short_sell_borrow][:price_target] = params[:price_target]

            order = ShortSellBorrow.new(params[:short_sell_borrow].merge(user: user))

            if order.place!(stock_details)
              render :json => { status: "Order placed." }
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
end


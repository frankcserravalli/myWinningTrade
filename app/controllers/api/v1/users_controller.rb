module Api
  module V1
    class UsersController < ApplicationController
      skip_before_filter :require_login, :require_acceptance_of_terms, :load_portfolio
      before_filter :valid_user_id
      respond_to :json

        def pending_date_time_transactions
          respond_with @user.date_time_transactions.pending
        end

        def pending_stop_loss_transactions
          respond_with @user.stop_loss_transactions.pending
        end

        def portfolio
          load_portfolio
          if @portfolio
            respond_with @portfolio
          else
            respond_with "invalid"
          end
        end

        def stock_info
          stock = Stock.find_by_symbol(params[:symbol])
          if stock
            user_stock = @user.user_stocks.where(stock_id: stock.id)
            if user_stock.any?
              respond_with user_stock
            else
              respond_with "User does not own stock"
            end
          else
            respond_with "Stock not yet traded"
          end
        end

        def stock_order_history
          stock = Stock.find_by_symbol(params[:symbol])
          if stock
            user_stock = @user.user_stocks.where(stock_id: stock.id).first
            if user_stock
              respond_with @user.orders.of_users_stock(user_stock.id) 
            else
              respond_with "User has not traded stock"
            end
          else
            respond_with "Stock not yet traded"
          end
        end

    end
  end
end

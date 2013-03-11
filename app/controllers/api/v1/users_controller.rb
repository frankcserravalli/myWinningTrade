module Api
  module V1
    class UsersController < ApplicationController
      skip_before_filter :require_login, :require_acceptance_of_terms, :load_portfolio
      skip_before_filter :valid_user_id
      skip_before_filter :require_iphone_login, :only => [:create, :authenticate]
      respond_to :json




      # call this to sign up a user
      #
      # Params Needed
      # =============
      # user (more details to come)
      # So you will send the json for user like this..
      # { "user": { "name": "", "email": "", etc etc } }
      #
      def create
        scrambled_token = scramble_token(Time.now, create_random_string)
        @user = User.new(params[:user])
        if @user.save
          render :json => { :user_id => @user.id, :ios_token => scrambled_token}
        else
          render :json => {}
        end
      end

      # Authenticate User and provide them an ios token
      #
      # Params Needed
      # =============
      # email
      # password
      #
      def authenticate
        scrambled_token = scramble_token(Time.now, create_random_string)
        @user = User.find_by_email(params[:email])#.try(:authenticate, params[:password])
        if @user
          render :json => { :user_id => @user.id, :ios_token => scrambled_token }
        else
          render :json => {}
        end
      end


      # Destroy an User's account
      #
      # Params Needed
      # =============
      # email
      # password
      #
      def destroy
        @user = User.find_by_email(params[:email])#.try(:authenticate, params[:password])
        if @user
          @user.destroy
          render :text => 'Account deleted'
        else
          render :json => {}
        end
      end

      def pending_date_time_transactions
        respond_with @user.date_time_transactions.pending
      end

      def pending_stop_loss_transactions
        respond_with @user.stop_loss_transactions.pending
      end

      def portfolio
        # load_portfolio takes in params[:user_id] to find the user_id
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

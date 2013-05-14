module Api
  module V1
    class UsersController < ApplicationController

      skip_before_filter :require_login, :require_acceptance_of_terms, :load_portfolio
      skip_before_filter :valid_user_id
      skip_before_filter :require_iphone_login, :only => [:create, :authenticate]
      skip_before_filter :verify_authenticity_token

      respond_to :json

      def create
        # Set params within user hash
        params[:user][:name] = params[:name]
        params[:user][:email] = params[:email]
        params[:user][:password] = params[:password]
        params[:user][:password_confirmation] = params[:password_confirmation]

        puts params[:user]

        # Set params to a new user
        @user = User.new(params[:user])

        if @user.save
          # we create a scrambled token
          scrambled_token = scramble_token(Time.now, @user.id)

          render :json => { :user_id => @user.id, :ios_token => scrambled_token}
        else
          render :json => { :status => "doesn't work" }
        end
      end

      def authenticate
        if params[:email].blank?
          @data_from_soc_network = request.env['omniauth.auth']

          @user = User.where(:provider => @data_from_soc_network['provider'],
                             :uid => @data_from_soc_network['uid']).first
          if @user
            scrambled_token = scramble_token(Time.now, @user.id)

            # Signed In, token is sent through because the user is signed in
            render :json => { :user_id => @user.id, :ios_token => scrambled_token }
          else
            # User doesn't exist, redirect to sign up page with info grabbed from facebook oauth
            render :json => @data_from_soc_network.to_json
          end
        else
          # We validate the user's password
          @user = User.find_by_email(params[:email].downcase).try(:authenticate, params[:password].downcase)
          if @user
            # Since everything is a goal, we create a scramble token then render it apart of the json
            scrambled_token = scramble_token(Time.now, @user.id)

            render :json => { :user_id => @user.id, :ios_token => scrambled_token }
          else
            render :json => {}
          end
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
        portfolio = load_portfolio(params[:user_id])

        puts "#####################"
        puts portfolio

        if portfolio
          render :json => portfolio.to_json
        else
          render :json => {}
        end
      end

      def stock_info
        stock = Stock.find_by_symbol(params[:symbol])
        if stock
          user_stock = @user.user_stocks.where(stock_id: stock.id)
          if user_stock.any?
            respond_with user_stock
          else
            render :json => {}
          end
        else
          render :json => {}
        end
      end

      def stock_order_history
        stock = Stock.find_by_symbol(params[:symbol])
        if stock
          user_stock = @user.user_stocks.where(stock_id: stock.id).first
          if user_stock
            respond_with @user.orders.of_users_stock(user_stock.id)
          else
            render :json => {}
          end
        else
          render :json => {}
        end
      end

    end
  end
end

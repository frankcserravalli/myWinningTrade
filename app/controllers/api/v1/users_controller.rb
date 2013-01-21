module Api
  module V1
    class UsersController < ApplicationController
      skip_before_filter :require_login, :require_acceptance_of_terms, :load_portfolio
      respond_to :json

        def pending_date_time_transactions
          @user = User.find_by_id(params[:user_id])
          if @user
            respond_with @user.date_time_transactions.pending
          else
            respond_with "invalid"
          end
        end

        def pending_stop_loss_transactions
          @user = User.find_by_id(params[:user_id])
          if @user
            respond_with @user.stop_loss_transactions.pending
          else
            respond_with "invalid"
          end
        end

        def portfolio
          load_portfolio
          if @portfolio
            respond_with @portfolio
          else
            respond_with "invalid"
          end
        end

    end
  end
end

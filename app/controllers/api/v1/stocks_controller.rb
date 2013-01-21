module Api
  module V1
    class StocksController < ApplicationController
      skip_before_filter :require_login, :require_acceptance_of_terms, :load_portfolio
      respond_to :json
      
      def search
        @suggestions = Finance.search_for_stock(params[:term].to_s)
        render json: @suggestions
      end
    
    end
  end
end

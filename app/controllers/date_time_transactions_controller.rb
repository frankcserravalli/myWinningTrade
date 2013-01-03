class DateTimeTransactionsController < ApplicationController

  def create
    
    @stock_details = Finance.current_stock_details(params[:stock_id]) or raise ActiveRecord::RecordNotFound
    @date_time_transaction = DateTimeTransaction.new(params[:date_time_transaction].merge(user: current_user))
    
    if @date_time_transaction.place!(@stock_details)
      flash[:notice] = "Order successfully placed"
    else
      flash[:alert] = "Order could not be placed"
    end
    
    redirect_to(stock_path(params[:stock_id]))

  end

end


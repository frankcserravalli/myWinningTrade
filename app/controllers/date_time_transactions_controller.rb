class DateTimeTransactionsController < ApplicationController
  after_filter :flash_alert, :only => :create
  
  def create
    
    Rails.logger.info params

    @stock_details = Finance.current_stock_details(params[:stock_id]) or raise ActiveRecord::RecordNotFound
    @date_time_transaction = DateTimeTransaction.new(params[:date_time_transaction].merge(user: current_user))
    
    if @date_time_transaction.place!(@stock_details)
      flash[:notice] = "Order successfully placed"
    end
    
    redirect_to(stock_path(params[:stock_id]))

  end

  def destroy
    @date_time_transaction = DateTimeTransaction.find_by_id(params[:stock_id])
    if @date_time_transaction && current_user.id == @date_time_transaction.user_id
      if @date_time_transaction.delete
        flash[:notice] = "Order successfully deleted"
      else
        flash[:alert] = "Order could not be deleted"
      end
    else
      flash[:alert] = "The order you are trying to delete does not exist"
    end
    redirect_to('/dashboard')
  end
  
  def flash_alert
    if !@date_time_transaction.errors.blank?
      flash[:alert] = @date_time_transaction.errors.values.join
    end
  end

end


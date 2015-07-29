class StopLossTransactionsController < ApplicationController
  after_filter :flash_alert, :only => :create
  
  def create
    
    Rails.logger.info params

    @stock_details = Finance.current_stock_details(params[:stock_id]) or raise ActiveRecord::RecordNotFound
    @stop_loss_transaction = StopLossTransaction.new(params[:stop_loss_transaction].merge(user: signed_user))
    
    if @stop_loss_transaction.place!(@stock_details)
      flash[:notice] = "Order successfully placed"
    end
    
    redirect_to(stock_path(params[:stock_id]))
  end

  def destroy
    @stop_loss_transaction = StopLossTransaction.find_by_id(params[:stock_id])
    if @stop_loss_transaction && signed_user.id == @stop_loss_transaction.user_id
      if @stop_loss_transaction.delete
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
    if !@stop_loss_transaction.errors.blank?
      flash[:alert] = @stop_loss_transaction.errors.values.join
    end
  end

end

class SellsController < ApplicationController
  before_filter {|controller| controller.when_to_execute_order('sell') }
  def create
    @stock_details = Finance.current_stock_details(params[:stock_id]) or raise ActiveRecord::RecordNotFound

    @order = SellTransaction.new(params[:sell].merge(user: current_user))

    if @order.place!(@stock_details)
      flash[:notice] = "Successfully sold #{@order.volume} shares from #{params[:stock_id]}"
      if params[:commit] == 'share'
        # Share to the social network
      end
      redirect_to(stock_path(params[:stock_id]))
    else
      redirect_to(stock_path(params[:stock_id]), alert: "#{@order.errors.values.join}")
    end
  end
end

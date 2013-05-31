class ShortSellBorrowsController < ApplicationController
  before_filter {|controller| controller.when_to_execute_order("short_sell_borrow") }

  def create
    @stock_details = Finance.current_stock_details(params[:stock_id]) or raise ActiveRecord::RecordNotFound
    puts "########## SHORT SELL BORROW ###############"
    puts params[:short_sell_borrow]
    @order = ShortSellBorrow.new(params[:short_sell_borrow].merge(user: current_user))

    if @order.place!(@stock_details)
      flash[:notice] = "Successfully shorted #{@order.volume} #{params[:stock_id]} for $#{-@order.value.round(2)}"
      redirect_to(stock_path(params[:stock_id]))
    else
      redirect_to(stock_path(params[:stock_id]), alert: "#{@order.errors.values.join}")
    end
  end
end

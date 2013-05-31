class ShortSellCoversController < ApplicationController
  def create
    @stock_details = Finance.current_stock_details(params[:stock_id]) or raise ActiveRecord::RecordNotFound

    puts "########## SHORT SELL COVER ###############"

    puts params[:short_sell_cover]

    @order = ShortTransaction.new(params[:short_sell_cover].merge(user: current_user))

    if @order.place!(@stock_details)
      flash[:notice] = "Successfully covered #{@order.volume} shares from #{params[:stock_id]}"
      redirect_to(stock_path(params[:stock_id]))
    else
      redirect_to(stock_path(params[:stock_id]), alert: "#{@order.errors.values.join}")
    end
  end
end

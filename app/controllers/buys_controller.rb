class BuysController < ApplicationController
  def create
    @stock_details = Finance.current_stock_details(params[:stock_id]) or raise ActiveRecord::RecordNotFound

    @order = Buy.new(params[:buy].merge(user: current_user))

    if @order.place!(@stock_details)
      flash[:notice] = "Successfully purchased #{@order.volume} #{params[:stock_id]} for $#{-@order.value.round(2)} (incl. $6 transaction fee)"
      redirect_to(stock_path(params[:stock_id]))
    else
      redirect_to(stock_path(params[:stock_id]), alert: "#{@order.errors.values.join}")
    end
  end
end

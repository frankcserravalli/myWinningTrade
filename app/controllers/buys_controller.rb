class BuysController < ApplicationController
  after_filter :flash_cover, :only => :create
  after_filter :flash_alert, :only => :create
  before_filter {|controller| controller.when_to_execute_order('buy') }

  def create
    @stock_details = Finance.current_stock_details(params[:stock_id]) or raise ActiveRecord::RecordNotFound

    @buy_order = Buy.new(params[:buy].merge(user: current_user))
    if @buy_order.place!(@stock_details)
      flash[:notice] = "Successfully purchased #{@buy_order.volume} #{params[:stock_id]} for $#{-@buy_order.value.round(2)} (incl. $6 transaction fee)"
      if params[:commit] == 'share'
        # Share to the social network
      end
      redirect_to(stock_path(params[:stock_id]))
    else
      redirect_to(stock_path(params[:stock_id]))
    end

  end

  def flash_cover
    if !@buy_order.flash_cover.blank?
      flash[:cover] = @buy_order.flash_cover
    end
  end

  def flash_alert
    if !@buy_order.errors.blank?
      flash[:alert] = @buy_order.errors.values.join
    end
  end
end

class SellsController < ApplicationController
  before_filter {|controller| controller.when_to_execute_order('sell') }
  def create
    @stock_details = Finance.current_stock_details(params[:stock_id]) or raise ActiveRecord::RecordNotFound

    @order = SellTransaction.new(params[:sell].merge(user: current_user))

    if @order.place!(@stock_details)
      if params[:commit] == 'share'
        session['oauth'] = Koala::Facebook::OAuth.new(298514626925253, "0de422445cad2b8ad09d8ecb8b748189", 'localhost:3000/sells/callback')

        redirect_to session['oauth'].url_for_oauth_code()
      else
        flash[:notice] = "Successfully sold #{@order.volume} shares from #{params[:stock_id]}"

        redirect_to(stock_path(params[:stock_id]))
      end
    else
      redirect_to(stock_path(params[:stock_id]), alert: "#{@order.errors.values.join}")
    end
  end

  def callback
    @graph = Koala::Facebook::GraphAPI.new(session['oauth'].get_access_token(params[:code]))
    @graph.put_wall_post("Testing out something. It works!")
    redirect_to dashboard_path
  end
end

class BuysController < ApplicationController
  after_filter :flash_cover, :only => :create
  after_filter :flash_alert, :only => :create
  before_filter(:except => [:callback]) { |controller| controller.when_to_execute_order('buy') }

  def create
    @stock_details = Finance.current_stock_details(params[:stock_id]) or raise ActiveRecord::RecordNotFound
    @buy_order = Buy.new(params[:buy].merge(user: current_user))
    if @buy_order.place!(@stock_details)
      if params[:commit] == 'share'
        linkedin_share
      else
        @stock_id = UserStock.find(@buy_order.user_stock_id)

        @stock_name = Stock.find(@stock_id.stock_id)

        flash[:notice] = "Successfully purchased #{@buy_order.volume} #{@stock_name.name} stocks for $#{-@buy_order.value.round(2)} (incl. $6 transaction fee)"

        redirect_to(stock_path(params[:stock_id]))
      end
    else
      redirect_to(stock_path(params[:stock_id]))
    end
  end

  def callback
    #TODO redirect to dashboard if user denies request

    client = LinkedIn::Client.new('7imqhpb5d9cm', 'dUtYyIdxvrqpbdXA')

    if session[:atoken].nil?
      pin = params[:oauth_verifier]

      atoken, asecret = client.authorize_from_request(session[:rtoken], session[:rsecret], pin)

      session[:atoken] = atoken

      session[:asecret] = asecret
    else
      client.authorize_from_access(session[:atoken], session[:asecret])
    end

    @current_user = current_user

    @buy_order = Buy.where(id: @current_user.id).last

    @stock_id = UserStock.find(@buy_order.user_stock_id)

    @stock_name = Stock.find(@stock_id.stock_id)

    response = "Successfully purchased #{@buy_order.volume} #{@stock_name.name} stocks for $#{-@buy_order.value.round(2)} (incl. $6 transaction fee)"

    client.add_share(:comment => response)

    flash[:notice] = response

    redirect_to(stock_path(@stock_id))
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

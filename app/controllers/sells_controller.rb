class SellsController < ApplicationController
  before_filter(:except => [:callback_facebook, :callback_linkedin]) {|controller| controller.when_to_execute_order('sell') }
  def create
    @stock_details = Finance.current_stock_details(params[:stock_id]) or raise ActiveRecord::RecordNotFound

    @order = SellTransaction.new(params[:sell].merge(user: current_user))

    if @order.place!(@stock_details)
      if params[:soc_network].eql? "linkedin"
        linkedin_share_connect("sells")
      elsif params[:soc_network].eql? "facebook"
        facebook_share_connect("sells")
      elsif params[:soc_network].eql? "twitter"
        @stock_id = UserStock.find(@order.user_stock)

        @stock = Stock.find(params[:stock_id])

        # This replaces spaces with the %20 symbol so that we can allow the URL to pass correctly to Twitter
        stock_name = @stock.name.gsub!(/\s/, "%20")

        redirect_to("http://twitter.com/share?text=I%20just%20sold%20" + @order.volume.to_s + "%20shares%20of%20" + @stock.symbol + "%20at%20$" + @buy_order.price.to_s + "%20per%20share.%20Learn%20to%20beat%20the%20market%20and%20out-trade%20your%20friends%20at%20mywinningtrade.com.")
      else
        flash[:notice] = "Successfully sold #{@order.volume} shares from #{params[:stock_id]}"

        redirect_to(stock_path(params[:stock_id]))
      end
    else
      redirect_to(stock_path(params[:stock_id]), alert: "#{@order.errors.values.join}")
    end
  end

  def callback_facebook
    @current_user = current_user

    @order = Order.where(user_id: @current_user.id).first

    @stock_id = UserStock.find(@order.user_stock_id)

    @stock = Stock.find(@stock_id.stock_id)

    response = "I just sold #{@order.volume} shares of #{@stock.symbol} at $#{@order.price} per share. Learn to beat the market and out-trade your friends with My Winning Trade."

    flash[:notice] = "Successfully sold #{@order.volume} shares from #{@stock.symbol}"

    @graph = Koala::Facebook::GraphAPI.new(session['oauth'].get_access_token(params[:code]))

    # Here we are preventing an error from Facebook when an user posts the same exact message twice
    begin
      @graph.put_wall_post(response + " on My Winning Trade.")
    rescue
      flash[:notice] = response + " but your Facebook post wasn't posted because Facebook doesn't allow duplicate posts."
    end
    redirect_to(stock_path(@stock.symbol))
  end

  def callback_linkedin
    @current_user = current_user

    @order = Order.where(user_id: @current_user.id).first

    @stock_id = UserStock.find(@order.user_stock_id)

    @stock = Stock.find(@stock_id.stock_id)

    response = "I just sold #{@order.volume} shares of #{@stock.symbol} at $#{@order.price} per share. Learn to beat the market and out-trade your friends with My Winning Trade."

    flash[:notice] = "Successfully sold #{@order.volume} shares from #{@stock.symbol}"

    if params.has_key? "oauth_problem"
      redirect_to(stock_path(@stock.symbol))
    else
      client = LinkedIn::Client.new('7imqhpb5d9cm', 'dUtYyIdxvrqpbdXA')

      if session[:atoken].nil?
        pin = params[:oauth_verifier]

        atoken, asecret = client.authorize_from_request(session[:rtoken], session[:rsecret], pin)

        session[:atoken] = atoken

        session[:asecret] = asecret
      else
        client.authorize_from_access(session[:atoken], session[:asecret])
      end

      client.add_share(:comment => response)

      redirect_to(stock_path(@stock.symbol))
    end
  end
end

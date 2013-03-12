class SellsController < ApplicationController

  # We don't want any orders executed when an user is visiting the linkedin or fb page when sigining in,
  # hence why we take it out
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

        @stock = Stock.find_by_symbol(params[:stock_id])

        # Here I'm doing a simple redirect to Twitter, unlike LinkedIn or Facebook Twitter's sharing on the wall
        # is much easier to grasp
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

    wall_post = "I just sold #{@order.volume} shares of #{@stock.symbol} at $#{@order.price} per share. Learn to beat the market and out-trade your friends with My Winning Trade."

    flash[:notice] = "Successfully sold #{@order.volume} shares from #{@stock.symbol}"

    @graph = Koala::Facebook::GraphAPI.new(session['oauth'].get_access_token(params[:code]))

    # Here we are preventing an error from Facebook when an user posts the same exact message twice
    begin
      # Post on user's facebook wall
      @graph.put_wall_post(wall_post)
    rescue
      flash[:notice] = "Your Facebook post wasn't posted because Facebook doesn't allow duplicate posts."
    end
    redirect_to(stock_path(@stock.symbol))
  end

  def callback_linkedin
    @current_user = current_user

    @order = Order.where(user_id: @current_user.id).first

    @stock_id = UserStock.find(@order.user_stock_id)

    @stock = Stock.find(@stock_id.stock_id)

    wall_post = "I just sold #{@order.volume} shares of #{@stock.symbol} at $#{@order.price} per share. Learn to beat the market and out-trade your friends with My Winning Trade."

    flash[:notice] = "Successfully sold #{@order.volume} shares from #{@stock.symbol}"

    # If an user decides to not post on Linkedin, then we redirect them to the stock page, otherwise, post on the wall.
    if params.has_key? "oauth_problem"
      flash[:notice] = "Successfully sold #{@order.volume} shares from #{@stock.symbol}"

      redirect_to(stock_path(@stock.symbol))
    else

      # Here we are sending the user to LinkedIn, then retrieving necessary tokens and posting info on the user's account
      client = LinkedIn::Client.new('xoc3a06gsosd', '41060V6v5K38dnV4')

      if session[:atoken].nil?
        pin = params[:oauth_verifier]

        atoken, asecret = client.authorize_from_request(session[:rtoken], session[:rsecret], pin)

        session[:atoken] = atoken

        session[:asecret] = asecret
      else
        client.authorize_from_access(session[:atoken], session[:asecret])
      end

      # Post on user's Linkedin profiel page
      client.add_share(:comment => wall_post)

      redirect_to(stock_path(@stock.symbol))
    end
  end
end

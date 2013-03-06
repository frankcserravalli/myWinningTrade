class BuysController < ApplicationController
  after_filter :flash_cover, :only => :create
  after_filter :flash_alert, :only => :create
  before_filter(:except => [:callback_facebook, :callback_linkedin]) { |controller| controller.when_to_execute_order('buy') }

  def create
    @stock_details = Finance.current_stock_details(params[:stock_id]) or raise ActiveRecord::RecordNotFound
    @buy_order = Buy.new(params[:buy].merge(user: current_user))
    if @buy_order.place!(@stock_details)
      if params[:soc_network].eql? "linkedin"
        linkedin_share_connect("buys")
      elsif params[:soc_network].eql? "facebook"
        facebook_share_connect("buys")
      elsif params[:soc_network].eql? "twitter"
        @stock_id = UserStock.find(@buy_order.user_stock_id)

        @stock = Stock.find(@stock_id.stock_id)

        # This replaces spaces with the %20 symbol so that we can allow the URL to pass correctly to Twitter
        stock_name = @stock.name.gsub!(/\s/, "%20")

        redirect_to("http://twitter.com/share?text=I%20just%20purchased%20" + @buy_order.volume.to_s + "%20shares%20of%20" + @stock.symbol + "%20at%20$" + @buy_order.price.to_s + "%20per%20share.%20Learn%20to%20beat%20the%20market%20and%20out-trade%20your%20friends%20at%20mywinningtrade.com.")
      else
        @stock_name = Stock.find_by_name(params[:stock_id])

        flash[:notice] = "Successfully purchased #{@buy_order.volume} #{@stock_name.name} stocks for $#{-@buy_order.value.round(2)} (incl. $6 transaction fee)."

        redirect_to(stock_path(params[:stock_id]))
      end
    else
      redirect_to(stock_path(params[:stock_id]))
    end
  end

  def callback_facebook
    @current_user = current_user

    @buy_order = Buy.where(user_id: @current_user.id).first

    @stock_id = UserStock.find(@buy_order.user_stock_id)

    @stock = Stock.find(@stock_id.stock_id)

    response = "I just purchased #{@buy_order.volume} shares of #{@stock.symbol} at $#{@buy_order.price} per share. Learn to beat the market and out-trade your friends with My Winning Trade."

    flash[:notice] = "Successfully purchased #{@buy_order.volume} #{@stock.symbol} stocks for $#{-@buy_order.value.round(2)} (incl. $6 transaction fee)."

    @graph = Koala::Facebook::GraphAPI.new(session['oauth'].get_access_token(params[:code]))

    # Here we are preventing an error from Facebook when an user posts the same exact message twice
    begin
      @graph.put_wall_post(response + "on My Winning Trade.")
    rescue
      flash[:notice] = response + " but your Facebook post wasn't posted because Facebook doesn't allow duplicate posts."
    end
    redirect_to(stock_path(@stock.symbol))
  end

  def callback_linkedin
    @current_user = current_user

    @buy_order = Buy.where(user_id: @current_user.id).first

    @stock_id = UserStock.find(@buy_order.user_stock_id)

    @stock = Stock.find(@stock_id.stock_id)

    response = "I just purchased #{@buy_order.volume} shares of #{@stock.symbol} at $#{@buy_order.price} per share. Learn to beat the market and out-trade your friends with My Winning Trade."

    flash[:notice] = "Successfully purchased #{@buy_order.volume} #{@stock.symbol} stocks for $#{-@buy_order.value.round(2)} (incl. $6 transaction fee)."

    if params.has_key? "oauth_problem" or !params[:oauth_problem].blank?
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

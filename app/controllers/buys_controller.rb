class BuysController < ApplicationController
  after_filter :flash_cover, :only => :create

  after_filter :flash_alert, :only => :create

  # We don't want any orders executed when an user is visiting the linkedin or fb page when sigining in,
  # hence why we take it out
  before_filter(:except => [:callback_facebook, :callback_linkedin]) { |controller| controller.when_to_execute_order('buy') }

  def create
    @stock_details = Finance.stock_details_for_symbol(params[:stock_id]) or raise ActiveRecord::RecordNotFound

    @buy_order = Buy.new(params[:buy].merge(user: signed_user))

    # Here we check if the user decided to post on any of his social networks info about his latest trade
    if @buy_order.place!(@stock_details)
      if params[:soc_network] == "linkedin"
        linkedin_share_connect("buys")
      elsif params[:soc_network] == "facebook"
        facebook_share_connect("buys")
      elsif params[:soc_network] == "twitter"
        @stock_id = UserStock.find(@buy_order.user_stock_id)

        @stock = Stock.find_by_symbol(params[:stock_id])

        # Here I'm doing a simple redirect to Twitter, unlike LinkedIn or Facebook Twitter's sharing on the wall
        # is much easier to grasp
        redirect_to("http://twitter.com/share?text=I%20just%20purchased%20" + @buy_order.volume.to_s + "%20shares%20of%20" + @stock.symbol + "%20at%20$" + @buy_order.price.to_s + "%20per%20share.%20Learn%20to%20beat%20the%20market%20and%20out-trade%20your%20friends%20at%20mywinningtrade.com.")
      else
        @stock_name = Stock.find_by_symbol(params[:stock_id])

        flash[:notice] = "Successfully purchased #{@buy_order.volume} #{@stock_name.name} stocks for $#{-@buy_order.value.round(2)} (incl. $6 transaction fee)."
        pp "#{flash[:notice]}"
        redirect_to(stock_path(params[:stock_id]))
      end
    else
      redirect_to(stock_path(params[:stock_id]))
    end
  end

  def callback_facebook
    @signed_user = signed_user

    @buy_order = Buy.where(user_id: @signed_user.id).first

    @stock_id = UserStock.find(@buy_order.user_stock_id)

    @stock = Stock.find(@stock_id.stock_id)

    wall_post = "I just purchased #{@buy_order.volume} shares of #{@stock.symbol} at $#{@buy_order.price} per share. Learn to beat the market and out-trade your friends with My Winning Trade."

    flash[:notice] = "Successfully purchased #{@buy_order.volume} #{@stock.symbol} stocks for $#{-@buy_order.value.round(2)} (incl. $6 transaction fee)."

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
    @signed_user = signed_user

    @buy_order = Buy.where(user_id: @signed_user.id).first

    @stock_id = UserStock.find(@buy_order.user_stock_id)

    @stock = Stock.find(@stock_id.stock_id)

    wall_post = "I just purchased #{@buy_order.volume} shares of #{@stock.symbol} at $#{@buy_order.price} per share. Learn to beat the market and out-trade your friends with My Winning Trade."

    flash[:notice] = "Successfully purchased #{@buy_order.volume} #{@stock.symbol} stocks for $#{-@buy_order.value.round(2)} (incl. $6 transaction fee)."

    # If an user decides to not post on Linkedin, then we redirect them to the stock page, otherwise, post on the wall.
    if params.has_key? "oauth_problem" or !params[:oauth_problem].blank?
      flash[:notice] = "Successfully purchased #{@buy_order.volume} #{@stock.symbol} stocks for $#{-@buy_order.value.round(2)} (incl. $6 transaction fee)."

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

      # Share comment on LinkedIn profile page
      client.add_share(:comment => wall_post)

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

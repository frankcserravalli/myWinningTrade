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
        twitter_share_connect("buys")
      else
        @stock_id = UserStock.find(@buy_order.user_stock_id)

        @stock_name = Stock.find(@stock_id.stock_id)

        flash[:notice] = "#{params[:soc_network]}Successfully purchased #{@buy_order.volume} #{@stock_name.name} stocks for $#{-@buy_order.value.round(2)} (incl. $6 transaction fee)"

        redirect_to(stock_path(params[:stock_id]))
      end
    else
      redirect_to(stock_path(params[:stock_id]))
    end
  end

  def callback_facebook
    @graph = Koala::Facebook::GraphAPI.new(session['oauth'].get_access_token(params[:code]))
    @graph.put_wall_post("Testing out something. It works!")
    redirect_to dashboard_path
  end

  def callback_linkedin
    @current_user = current_user

    @buy_order = Buy.where(user_id: @current_user.id).first

    @stock_id = UserStock.find(@buy_order.user_stock_id)

    @stock = Stock.find(@stock_id.stock_id)

    response = "Successfully purchased #{@buy_order.volume} #{@stock.name} stocks for $#{-@buy_order.value.round(2)} on My Winning Trade."

    flash[:notice] = response

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

  def callback_twitter
    #Twitter.update("I'm tweeting with @gem!")
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

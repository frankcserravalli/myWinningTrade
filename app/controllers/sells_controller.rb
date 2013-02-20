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
        redirect_to "http://twitter.com/share?text=Some%20text%20goes%20here"
      else
        flash[:notice] = "Successfully sold #{@order.volume} shares from #{params[:stock_id]}"

        redirect_to(stock_path(params[:stock_id]))
      end
    else
      redirect_to(stock_path(params[:stock_id]), alert: "#{@order.errors.values.join}")
    end
  end

  def callback_facebook
    @graph = Koala::Facebook::GraphAPI.new(session['oauth'].get_access_token(params[:code]))

    @graph.put_wall_post("Testing out something. It works!")

    redirect_to dashboard_path
  end

  def callback_linkedin
    @current_user = current_user

    @order = Order.where(user_id: @current_user.id).first

    @stock_id = UserStock.find(@order.user_stock_id)

    @stock = Stock.find(@stock_id.stock_id)

    response = "Successfully sold #{@order.volume} shares from #{@stock.name} on My Winning Trade."

    flash[:notice] = response

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


  def callback_twitter
    #Twitter.update("I'm tweeting with @gem!")
  end
end

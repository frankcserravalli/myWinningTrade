class SellsController < ApplicationController
  before_filter(:except => [:callback]) {|controller| controller.when_to_execute_order('sell') }
  def create
    @stock_details = Finance.current_stock_details(params[:stock_id]) or raise ActiveRecord::RecordNotFound

    @order = SellTransaction.new(params[:sell].merge(user: current_user))

    if @order.place!(@stock_details)
      if params[:soc_network].eql? "linkedin"
        linkedin_share_connect("sells")
      elsif params[:soc_network].eql? "facebook"
        facebook_share_connect("sells")
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
    #TODO redirect to stock if user denies request

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

    response = "Successfully sold #{@order.volume} shares from #{params[:stock_id]}"

    client.add_share(:comment => response)

    flash[:notice] = response

    redirect_to(stock_path(@stock.symbol))
  end

end

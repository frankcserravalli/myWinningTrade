class OrdersController < ApplicationController
  before_filter :authenticate_user!
  def index
    send_data current_user.export_orders_as_csv, filename: "Orders export #{Time.now}.csv"
  end
end

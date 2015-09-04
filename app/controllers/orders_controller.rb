class OrdersController < ApplicationController
  def index
    send_data signed_user.export_orders_as_csv, filename: "Orders export #{Time.now}.csv"
  end
end

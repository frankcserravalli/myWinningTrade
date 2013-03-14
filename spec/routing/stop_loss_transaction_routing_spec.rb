require 'spec_helper'

describe "Stop Loss Transactions Routing" do
  it "should route to buys#callback_linkedin" do
    expect(post: '/stock/1/stop_loss_transaction').to route_to({ controller: 'stop_loss_transactions', action: 'create', stock_id: "1" })
  end

  it "should route to buys#callback_faccebook" do
    expect(delete: '/stock/1/stop_loss_transaction').to route_to({ controller: 'stop_loss_transactions', action: 'destroy', stock_id: "1" })
  end
end
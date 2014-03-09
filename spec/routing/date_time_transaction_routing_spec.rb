require 'spec_helper'

describe "Date Time Transaction Routing" do
  it "should route to datetimetransaction#callback_linkedin" do
    expect(post: '/stock/1/date_time_transaction').to route_to({ controller: 'date_time_transactions', action: 'create', stock_id: "1" })
  end
  it "should route to datetimetransaction#callback_faccebook" do
    expect(delete: '/stock/1/date_time_transaction').to route_to({ controller: 'date_time_transactions', action: 'destroy', stock_id: "1" })
  end
end



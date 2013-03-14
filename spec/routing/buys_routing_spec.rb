require 'spec_helper'

describe "Buys Routing" do
  it "should route to buys#callback_linkedin" do
    expect(get: '/buys/callback_linkedin').to route_to({ controller: 'buys', action: 'callback_linkedin' })
  end
  it "should route to buys#callback_faccebook" do
    expect(get: '/buys/callback_facebook').to route_to({ controller: 'buys', action: 'callback_facebook' })
  end
  it "should route to buys#create" do
    expect(post: '/stock/1/buy').to route_to({ controller: 'buys', action: 'create', stock_id: "1" })
  end
end

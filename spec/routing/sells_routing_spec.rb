require 'spec_helper'

describe "Sells Routing" do
  it "should route to sells#callback_linkedin" do
    expect(get: '/sells/callback_linkedin').to route_to({ controller: 'sells', action: 'callback_linkedin' })
  end
  it "should route to sells#callback_faccebook" do
    expect(get: '/sells/callback_facebook').to route_to({ controller: 'sells', action: 'callback_facebook' })
  end
  it "should route to sells#create" do
    expect(post: '/stock/GOOG/sell').to route_to({ controller: 'sells', action: 'create', stock_id: "GOOG" })
  end
end


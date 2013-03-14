require 'spec_helper'

describe "Sessions Routing" do
  it "should route to sessions#new" do
    expect(get: '/login').to route_to({ controller: 'sessions', action: 'new' })
  end
  it "should route to buys#callback_faccebook" do
    expect(get: '/logout').to route_to({ controller: 'sessions', action: 'destroy' })
  end
  it "should route to buys#create" do
    expect(post: '/auth/facebook/callback').to route_to({ controller: 'sessions', action: 'create', provider: "facebook" })
  end
end

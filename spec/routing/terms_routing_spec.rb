require 'spec_helper'

describe "Terms Routing" do
  it "should route to terms#new" do
    expect(get: '/terms').to route_to({ controller: 'terms', action: 'show' })
  end

  it "should route to terms#callback_faccebook" do
    expect(post: '/terms/accept').to route_to({ controller: 'terms', action: 'accept' })
  end
end

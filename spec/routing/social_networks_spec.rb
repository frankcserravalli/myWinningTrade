require 'spec_helper'

describe "Social Network Routing" do
  it "should route social_networks#authenticate" do
    expect(post: '/api/v1/auth/:provider/callback').to route_to({ controller: 'api/v1/social_networks', action: 'authenticate',  format: 'json' })
  end

end
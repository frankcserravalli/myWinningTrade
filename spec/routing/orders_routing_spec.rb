require 'spec_helper'

describe "Orders Routing" do
  it "should route to orders#index" do
    expect(get: '/orders').to route_to({ controller: 'orders', action: 'index' })
  end
end

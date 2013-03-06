require 'spec_helper'

describe "Subscriptions Routing" do
  it "should route to subscriptions#show" do
    expect(get: 'subscriptions').to route_to({ controller: 'subscriptions', action: 'show' })
  end

  it "should route to subscriptions#create" do
    expect(post: 'subscriptions/create').to route_to({ controller: 'subscriptions', action: 'create' })
  end

  it "should route to subscriptions#destroy" do
    expect(delete: 'subscriptions/destroy').to route_to({ controller: 'subscriptions', action: 'destroy' })
  end
end


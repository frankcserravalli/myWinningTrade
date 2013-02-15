require 'spec_helper'

describe "User Routing" do

  it "should route users#delete" do
    expect(delete: 'api/v1/users/destroy').to route_to({ controller: 'api/v1/users', action: 'destroy', format: 'json' })
  end

  it "should route users#authenticate" do
    expect(post: 'api/v1/users/authenticate').to route_to({ controller: 'api/v1/users', action: 'authenticate', format: 'json' })
  end

  it "should route users#create" do
    expect(post: 'api/v1/users/create').to route_to({ controller: 'api/v1/users', action: 'create', format: 'json' })
  end

end
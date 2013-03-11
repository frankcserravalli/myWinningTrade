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

  it "should route social_networks#authenticate" do
    expect(post: '/api/v1/auth/:provider/callback').to route_to({ controller: 'api/v1/users', action: 'authenticate',  format: 'json', provider: ':provider' })
  end
=begin
  it "should route to users#show" do
    expect(get: 'users/profile').to route_to({ controller: 'users', action: 'profile' })
  end

  it "should route to users#edit" do
    expect(get: 'users/edit').to route_to({ controller: 'users', action: 'edit' })
  end

  it "should route to users#update" do
    expect(put: 'users/update').to route_to({ controller: 'users', action: 'update' })
  end
=end
end
require 'spec_helper'

describe "User Routing" do

  it "should route to users#show" do
    expect(get: 'users/profile').to route_to({ controller: 'users', action: 'profile' })
  end

  it "should route to users#edit" do
    expect(get: 'users/edit').to route_to({ controller: 'users', action: 'edit' })
  end

  it "should route to users#update" do
    expect(put: 'users/update').to route_to({ controller: 'users', action: 'update' })
  end

end
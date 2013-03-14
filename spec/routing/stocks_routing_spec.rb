require 'spec_helper'

describe "Stocks Routing" do
  it "should route to stocks#show" do
    expect(get: '/stock/show').to route_to({ controller: 'stock', action: 'show', id: 'show' })
  end

  it "should route to stocks#details" do
    expect(get: '/stock/details').to route_to({ controller: 'stock', action: 'details' })
  end

  it "should route to stocks#search" do
    expect(get: '/stock/search').to route_to({ controller: 'stock', action: 'search' })
  end

  it "should route to stocks#portfolio" do
    expect(get: '/stock/portfolio').to route_to({ controller: 'stock', action: 'portfolio' })
  end

  it "should route to stocks#price_history" do
    expect(get: '/stock/GOOG/price_history').to route_to({ controller: 'stock', action: 'price_history', id: 'GOOG' })
  end

  it "should route to stocks#dashboard" do
    expect(get: '/dashboard').to route_to({ controller: 'stock', action: 'dashboard' })
  end

  it "should route to stocks#trading_analysis" do
    expect(get: '/user/trading_analysis').to route_to({ controller: 'stock', action: 'trading_analysis' })
  end
end

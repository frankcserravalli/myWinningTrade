require 'spec_helper'

describe User do
  it "should receive an initial account balance when being created" do
    User.new.account_balance.should == User::OPENING_BALANCE
  end

  it "method should turn user's premium subscription to true" do
    @user = FactoryGirl.create(:user)

    @user.upgrade_subscription

    @user.premium_subscription.should.eql? true
  end

  it { should have_one(:subscription_customer) }
end

require 'spec_helper'

describe User do
  it "should receive an initial account balance when being created" do
    User.new.account_balance.should == User::OPENING_BALANCE
  end

  it "upgrade_subscription method should turn user's premium subscription to true" do
    @user = FactoryGirl.create(:user)

    @user.upgrade_subscription

    @user.premium_subscription.should.eql? true
  end

  it "cancel_subscription method should turn user's premium subscription to false" do
    @user = FactoryGirl.create(:user, premium_subscription: true)

    @user.cancel_subscription

    @user.premium_subscription.should.eql? false
  end

  it { should have_one(:subscription_customer) }

  it { should_not allow_mass_assignment_of(:account_balance) }
end

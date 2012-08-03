require 'spec_helper'

describe "User" do
  it "should receive an initial account balance when being created" do
    User.new.account_balance.should == User::OPENING_BALANCE
  end
end

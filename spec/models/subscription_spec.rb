require 'spec_helper'

describe Subscription do
  it { should_not allow_mass_assignment_of(:user_id) }

  it { should_not allow_mass_assignment_of(:payment_option) }

  it { should_not allow_mass_assignment_of(:customer_id) }

  it { should belong_to :user }

  describe "methods" do
    describe "add customer" do
      before :each do
        @user = FactoryGirl.create(:user)
        SubscriptionCustomer.add_customer(@user.id, "asdf", "two")
      end

      it "should create an user" do
        expect do
          SubscriptionCustomer.add_customer(@user.id, "asdf", "two")
        end.to change{ SubscriptionCustomer.count }.by(1)
      end
    end
  end
end

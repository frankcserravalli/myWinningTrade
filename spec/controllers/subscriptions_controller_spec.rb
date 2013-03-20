require 'spec_helper'

describe SubscriptionsController do
  before do
    @user = authenticate
  end

  context "a good user" do
    context "when visiting the delete subscription page" do
      before :each do
        @user1 = FactoryGirl.create(:user)
        @customer = FactoryGirl.create(:subscription, user_id: @user1.id)
      end

      it "respond with redirect" do
        delete :destroy, user_id: @user1.id

        should respond_with(:redirect)
      end

      it "sets the flash" do
        delete :destroy, user_id: @user1.id

        should set_the_flash.to "Subscription cancelled."
      end

      it "redirect" do
        delete :destroy, user_id: @user1.id

        should redirect_to(subscriptions_path)
      end

      it "should not have an subscription deleted" do
        expect do
          delete :destroy, user_id: @user1.id
        end.to change{ Subscription.count }.by(-1)
      end
    end


    context "when visiting the user subscription page" do
      before do
        get :show
      end

      it { should respond_with(:success) }

      it { should render_template(:show) }

      it { should assign_to(:user) }
    end
  end

  context "a bad user" do
    context "when deleting a subscription" do
      before do
        @user1 = FactoryGirl.create(:user)
        @stripe_token = "tok_1RoU8AGFjdOeqU"
        customer = Stripe::Customer.create(
            :card => @stripe_token,
            :description => @user1.email,
            :plan => "two",
            :email => @user1.email
        )

        # Add Subscription Customer into DB
        Subscription.add_customer(@user1.id, customer.id, "two")
      end

      before :each do
        @customer = FactoryGirl.create(:subscription, user_id: @user1.id)
      end

      it "should not have an subscription deleted" do
        expect do
          delete :destroy
        end.to change{ Subscription.count }.by(0)
      end

      it "respond with redirect" do
        delete :destroy

        should respond_with(:redirect)
      end

      it "sets the flash" do
        delete :destroy

        should set_the_flash.to "Subscription cannot be cancelled. Please contact the website."
      end

      it "redirect" do
        delete :destroy

        should redirect_to(subscriptions_path)
      end
    end
  end
end
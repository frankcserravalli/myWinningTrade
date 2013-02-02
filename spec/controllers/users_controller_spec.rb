require 'spec_helper'

describe UsersController do
  before do
    @user = authenticate
  end

  context "a good user" do

    context "when visiting the profile" do
      before do
        get :profile
      end

      it { should respond_with(:success) }
      it { should render_template(:profile) }
      it { should assign_to(:user) }

    end

    context "when visiting the the user edit page" do
      before do
        get :edit
      end

      it { should respond_with(:success) }
      it { should render_template(:edit) }
      it { should assign_to(:user) }

    end

    context "when visiting the user subscription page" do
      before do
        get :subscription
      end

      it { should respond_with(:success) }
      it { should render_template(:subscription) }
      it { should assign_to(:user) }

    end

    context "when updating their profile" do
      before do
        put :update, id: @user.id, user: {'name' => 'Billy Jean'}
      end

      it { should respond_with(:redirect) }
      it { should redirect_to(profile_path)  }
      it { should assign_to(:user) }
      it { should set_the_flash.to('Profile successfully updated.')}
      it "changes user's attributes" do
        @user.reload
        @user.name.should eq("Billy Jean")
      end
    end

  end

end
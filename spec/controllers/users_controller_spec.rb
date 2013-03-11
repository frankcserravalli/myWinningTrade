require 'spec_helper'

=begin
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
=end


describe Api::V1::UsersController do
  before do
    @token = scramble_token(Time.now, create_random_string)
  end

  describe "post authenticate" do
    context "with an user who does everything right and signs in w/o social network" do
      before :each do
        @user = FactoryGirl.create(:user)
      end

      it "returns with an ios token" do
        post :authenticate, email: @user.email, password: @user.password

        parsed_body = JSON.parse(response.body)

        parsed_body["ios_token"].should.is_a? String
      end

      it "returns with the signed in user" do
        post :authenticate, email: @user.email, password: @user.password

        parsed_body = JSON.parse(response.body)

        parsed_body["user_id"].should == @user.id
      end

      it "returns http success" do
        post :authenticate, email: @user.email, password: @user.password
        response.should be_success
      end
    end

    context "with an user who does everything wrong and signs in w/o social network" do
      before :each do
        @user = FactoryGirl.create(:user)
      end
      it "returns with no ios token" do
        post :authenticate, email: @user.email

        parsed_body = JSON.parse(response.body)

        parsed_body.should == {}
      end
    end
  end


  describe "post create" do
    context "with an user who does everything right" do
      it "returns http success" do
        post :create, user: FactoryGirl.attributes_for(:user)

        response.should be_success
      end

      it "returns with an ios token" do
        post :create, user: FactoryGirl.attributes_for(:user)

        parsed_body = JSON.parse(response.body)

        parsed_body["ios_token"].should.is_a? String
      end

      it "returns with an created user" do
        post :create, user: FactoryGirl.attributes_for(:user)

        parsed_body = JSON.parse(response.body)

        parsed_body["user_id"].should == User.last.id
      end

      it "should create a new user" do
        expect do
          post :create, user: FactoryGirl.attributes_for(:user)
        end.to change{ User.count }.by(1)
      end
    end

    context "with an user who does everything wrong" do

      # TODO turn one when validations set up for model
      it "should get returned an error message" do
        post :create, user: FactoryGirl.attributes_for(:user, provider: "")

        response.body.should == "{}"
      end

      it "returns with no ios token" do
        post :create, user: FactoryGirl.attributes_for(:user, provider: "")

        parsed_body = JSON.parse(response.body)

        parsed_body["ios_token"].should == nil
      end

      it "should not create a new user" do
        expect do
          post :create, user: FactoryGirl.attributes_for(:user, provider: "")
        end.to change{ User.count }.by(0)
      end

    end
  end

  describe "post authenticate" do
    context "with an user who does everything right" do
      before :each do
        @user = FactoryGirl.create(:user)
      end

      it "returns with an ios token" do
        post :authenticate, email: @user.email #, password: @user.password

        parsed_body = JSON.parse(response.body)

        parsed_body["ios_token"].should.is_a? String
      end

      it "returns with the signed in user" do
        post :authenticate, email: @user.email #, password: @user.password

        parsed_body = JSON.parse(response.body)

        parsed_body["user_id"].should == User.last.id
      end

      it "returns http success" do
        post :authenticate, email: @user.email #, password: @user.password
        response.should be_success
      end
    end

    context "with an user who does everything wrong" do
      before :each do
        @user = FactoryGirl.create(:user)
      end
      it "returns with no ios token" do
        post :authenticate, email: @user.email

        parsed_body = JSON.parse(response.body)

        parsed_body["ios_token"].should.nil?
      end
    end
  end

  describe "delete destroy" do
    context "with an user who does everything right" do
      before :each do
        @user = FactoryGirl.create(:user)
      end

      it "returns http success" do
        delete :destroy, ios_token: @token, email: @user.email #, password: @user.password
        response.should be_success
      end

      it "deletes the user from the records" do
        expect do
          delete :destroy, ios_token: @token, email: @user.email #, password: @user.password
        end.to change{ User.count }.by(-1)
      end
    end

    context "with an user who does everything wrong" do
      before :each do
        @user = FactoryGirl.create(:user)
      end

      it "doesn't delete the user when there is no ios token" do
        expect do
          delete :destroy #, password: @user.password
        end.to change{ User.count }.by(0)
      end

      it "doesn't delete the user when there is no email" do
        expect do
          delete :destroy #, password: @user.password
        end.to change{ User.count }.by(0)
      end
    end
  end
end


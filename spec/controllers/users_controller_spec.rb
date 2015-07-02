require 'spec_helper'
require 'devise'

describe UsersController do
  include Devise::TestHelpers
  describe '#GET user#profile' do
    context 'when user is signed in' do
      before(:each) do
        sign_in FactoryGirl.create(:user, :sign_in)
      end
      it 'has a 200 response status' do
        get :profile
        expect(response.status).to be(200)
      end
      it 'renders the profile view' do
        get :profile
        expect(response).to render_template('users/profile')
      end
    end

    context 'when user is not signed in' do
      it 'redirects to sign in view' do
        get :profile
        expect(response).to redirect_to('/users/sign_in')
      end
      it 'has a 302 response status' do
        get :profile
        expect(response.status).to eq(302)
      end
    end
  end

  describe '#GET user#edit' do
    context 'when user is signed in' do
      before(:each) do
        sign_in FactoryGirl.create(:user, :sign_in)
      end
      it 'renders edit view' do
        get :edit
        expect(response).to render_template :edit
      end
      it 'has a response status code of 200' do
        get :edit
        expect(response.status).to eq(200)
      end
    end
    context 'when user is not signed in' do
      it 'redirects to sign in view' do
        get :profile
        expect(response).to redirect_to('/users/sign_in')
      end
      it 'has a 302 response status' do
        get :profile
        expect(response.status).to eq(302)
      end
    end
  end

  describe '#PUT user#update' do
    let(:user) { FactoryGirl.create(:user, :sign_in) }
    context 'when user is signed and has valid args' do
      before(:each) do
        sign_in user
      end
      it 'has a response status of 302' do
        put :update, user: FactoryGirl.attributes_for(:user, :update), teacher_request: false
        expect(response.status).to eq(302)
      end
      it 'updates the user with the new data' do
        name = user.name
        put :update, user: FactoryGirl.attributes_for(:user, :update), teacher_request: false
        user.reload
        expect(name).not_to eq(user.name)
      end
      it 'renders the profile view' do
        put :update, user: FactoryGirl.attributes_for(:user, :update), teacher_request: false
        expect(response).to redirect_to profile_url
      end
    end
    context 'when user is signed and has valid args with teacher req' do
      before(:each) do
        sign_in user
      end
      it 'has a response status of 302' do
        put :update, user: FactoryGirl.attributes_for(:user, :update), teacher_request: true
        expect(response.status).to eq(302)
      end
      it 'updates user with new data' do
        name = user.name
        put :update, user: FactoryGirl.attributes_for(:user, :update), teacher_request: true
        user.reload
        expect(user.name).not_to eq(name)
      end
      it 'creates a Pending teacher record' do
        expect do
          put :update, user: FactoryGirl.attributes_for(:user, :update), teacher_request: true
        end.to change(PendingTeacher, :count).by(1)
      end
      it 'renders profile view' do
        put :update, user: FactoryGirl.attributes_for(:user, :update), teacher_request: true
        expect(response).to redirect_to profile_url
      end
    end
    context 'when user is signed in with invalid args' do
      before(:each) do
        sign_in user
      end
      it 'has a response status of 200' do
        put :update, user: FactoryGirl.attributes_for(:user, name: ''), teacher_request: false
        expect(response.status).to eq(200)
      end
      it 'does not update user with new data' do
        name = user.name
        put :update, user: FactoryGirl.attributes_for(:user, name: ''), teacher_request: false
        user.reload
        expect(user.name).to eq(name)
      end
      it 'renders the edit view' do
        put :update, user: FactoryGirl.attributes_for(:user, name: ''), teacher_request: false
        expect(response).to render_template :edit
      end
    end
    context 'when user is not signed in' do
    end
  end
end

describe Api::V1::UsersController do
  before do
    @user = FactoryGirl.create(:user, :sign_in)
    @token = scramble_token(Time.now, @user.id)
  end

  describe 'post authenticate' do
    context 'w/o social network' do
      context 'with an user who does everything right and signs in' do
        it 'returns with an ios token' do
          post :authenticate, email: @user.email, password: @user.password
          response = rubify# JSON.parse(response.body)
          expect(response.ios_token).to be_a(String)
          # parsed_body['ios_token'].should.is_a? String
        end

        xit 'returns with the signed in user' do
          post :authenticate, email: @user.email, password: @user.password
          parsed_body = JSON.parse(response.body)
          parsed_body['user_id'].should == @user.id
        end

        it 'returns http success' do
          post :authenticate, email: @user.email, password: @user.password
          response.should be_success
        end
      end

      context 'with an user who does everything wrong and signs in' do
        it 'returns with no ios token' do
          post :authenticate, email: @user.email
          parsed_body = JSON.parse(response.body)
          parsed_body.should == {}
        end
      end
    end

    context 'via a social network' do
      context 'with an user who does everything right' do
        before :each do
          request.env['omniauth.auth'] = { provider: @user.provider, uid: @user.uid }
          post :authenticate, email: @user.email, password: @user.password
        end

        it 'returns with an ios token' do
          parsed_body = JSON.parse(response.body)
          parsed_body.should.is_a? String
        end

        xit 'returns with the signed in user' do
          parsed_body = JSON.parse(response.body)
          user_id = parsed_body['user_id']
          user_id.should == @user.id
        end

        it 'returns http success' do
          response.should be_success
        end
      end

      context 'with an user who does everything wrong' do
        before :each do
          request.env['omniauth.auth'] = { :provider => 'not the real provider', :uid => @user.uid }
        end

        it 'returns with no ios token' do
          post :authenticate
          parsed_body = JSON.parse(response.body)
          parsed_body['ios_token'].should.nil?
        end
      end
    end
  end

  describe 'post create' do
    context 'with an user who does everything right' do
      it 'returns http success' do
        post :create, user: FactoryGirl.attributes_for(:user)
        response.should be_success
      end

      it 'returns with an ios token' do
        post :create, user: FactoryGirl.attributes_for(:user)
        parsed_body = JSON.parse(response.body)
        parsed_body['ios_token'].should.is_a? String
      end

      it 'returns with an created user' do
        post :create, user: FactoryGirl.attributes_for(:user)
        parsed_body = JSON.parse(response.body)
        parsed_body['user_id'].should == User.last.id
      end

      it 'should create a new user' do
        expect do
          post :create, user: FactoryGirl.attributes_for(:user)
        end.to change{ User.count }.by(1)
      end
    end

    context 'with an user who does everything wrong' do

      # TODO turn one when validations set up for model
      it 'should get returned an error message' do
        post :create, user: FactoryGirl.attributes_for(:user, provider: '')
        response.body.should == '{}'
      end

      it 'returns with no ios token' do
        post :create, user: FactoryGirl.attributes_for(:user, provider: '')
        parsed_body = JSON.parse(response.body)
        parsed_body['ios_token'].should == nil
      end

      it 'should not create a new user' do
        expect do
          post :create, user: FactoryGirl.attributes_for(:user, provider: '')
        end.to change{ User.count }.by(0)
      end
    end
  end

  describe 'delete destroy' do
    context 'with an user who does everything right' do
      before :each do
        @user = FactoryGirl.create()
      end

      it 'returns http success' do
        delete :destroy, ios_token: @token, email: @user.email #, password: @user.password
        response.should be_success
      end

      it 'deletes the user from the records' do
        expect do
          delete :destroy, ios_token: @token, email: @user.email #, password: @user.password
        end.to change{ User.count }.by(-1)
      end
    end

    context 'with an user who does everything wrong' do
      before :each do
        @user = FactoryGirl.create(:user, :sign_in)
      end

      it 'does not delete the user when there is no ios token' do
        expect do
          delete :destroy #, password: @user.password
        end.to change{ User.count }.by(0)
      end

      it 'does not delete the user when there is no email' do
        expect do
          delete :destroy #, password: @user.password
        end.to change{ User.count }.by(0)
      end
    end
  end

  describe 'post portfolio' do
    context 'with an user who does everything right' do
      before :each do
        @user = FactoryGirl.create(:user, :sign_in)
      end

      it 'returns http success' do
        post :portfolio, ios_token: @token, user_id: @user.id
        response.should be_success
      end

      it 'returns with a portfolio' do
        post :portfolio, ios_token: @token, user_id: @user.id #, password: @user.password

        parsed_body = JSON.parse(response.body)

        parsed_body['current_value'].should == 0
      end

    end
  end
end


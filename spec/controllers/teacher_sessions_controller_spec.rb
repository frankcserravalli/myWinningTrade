require 'spec_helper'
require 'devise'

describe TeacherSessionsController do
  include Devise::TestHelpers
  describe '#GET new' do
    before(:each) do
      @request.env['devise.mapping'] = Devise.mappings[:user]
    end
    it 'renders new view' do
      get :new
      expect(response).to render_template ""
    end
    it 'returns a status code of 200' do
      get :new
      expect(response.status).to eq(200)
    end
  end
  describe '#POST create' do
  end
  describe '#GET request upgrade' do
    let(:user) { FactoryGirl.create(:user, :sign_in) }
    before(:each) do
      @request.env['devise.mapping'] = Devise.mappings[:user]
      sign_in user
    end
    context 'when it does not have a pending teacher' do
      it 'flashes request pending' do
        get :request_upgrade
        expect(flash[:notice]).to eq('Request Sent!')
      end
      it 'has a status code of 302' do
        get :request_upgrade
        expect(response.status).to eq(302)
      end
      it 'redirects to profile' do
        get :request_upgrade
        expect(response).to redirect_to profile_url
      end
    end
    context 'when it has a pending teacher' do
      before(:each) do
        get :request_upgrade
      end
      it 'flashes request pending' do
        get :request_upgrade
        expect(flash[:notice]).to eq('Request Pending!')
      end
      it 'has a status code of 302' do
        get :request_upgrade
        expect(response.status).to eq(302)
      end
      it 'redirects to profile' do
        get :request_upgrade
        expect(response).to redirect_to profile_url
      end
    end
  end
  describe '#POST verify' do
    before(:each) do
      @user = FactoryGirl.create(:user, :sign_in)
      @request.env['devise.mapping'] = Devise.mappings[:user]
      sign_in @user
      get :request_upgrade
    end
    it 'changes the user group to teacher' do
      post :verify, user_id: @user.id
      @user.reload
      expect(@user.group).to eq('teacher')
    end
    it 'has a status code of 302' do
      post :verify, user_id: @user.id
      expect(response.status).to eq(302)
    end
    it 'redirects to teacher pending url' do
      post :verify, user_id: @user.id
      expect(response).to redirect_to teacher_pending_url
    end
  end
  describe '#POST remove pending' do
    before(:each) do
      @user = FactoryGirl.create(:user, :sign_in)
      @request.env['devise.mapping'] = Devise.mappings[:user]
      sign_in @user
      get :request_upgrade
    end
    it 'changes the user group to teacher' do
      post :remove_pending, user_id: @user.id
      @user.reload
      expect(@user.pending_teacher).to eq(nil)
    end
    it 'has a status code of 302' do
      post :remove_pending, user_id: @user.id
      expect(response.status).to eq(302)
    end
    it 'redirects to teacher pending url' do
      post :remove_pending, user_id: @user.id
      expect(response).to redirect_to teacher_pending_url
    end
  end
  describe '#GET pending' do
    context 'when user is admin' do
      let(:user) { FactoryGirl.create(:user, :sign_in) }
      before(:each) do
        @request.env['devise.mapping'] = Devise.mappings[:user]
        sign_in user
      end
      it 'has a response status code of 200' do
        get :pending
        expect(response.status).to eq(200)
      end
      it 'renders the pending view' do
        get :pending
        expect(response).to render_template :pending
      end
    end
    context 'when user is not admin' do
      let(:user) do
        FactoryGirl.create(:user, :sign_in, email: Faker::Internet.email)
      end
      before(:each) do
        @request.env['devise.mapping'] = Devise.mappings[:user]
        sign_in user
      end
      it 'redirects to groups url' do
        get :pending
        expect(response).to redirect_to groups_url
      end
      it 'has a response status code of 302' do
        get :pending
        expect(response.status).to eq(302)
      end
    end
  end
end

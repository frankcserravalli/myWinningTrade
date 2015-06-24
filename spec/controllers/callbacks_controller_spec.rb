require 'spec_helper'
require 'ostruct'
describe CallbacksController do
  include Devise::TestHelpers
  describe 'Google Callback' do
    before(:each) do
      @request.env['devise.mapping'] = Devise.mappings[:user]
      @request.env['omniauth.auth'] = OmniAuth::AuthHash.new(
        provider: 'google_oauth2', uid: '121322342341',
        info: OpenStruct.new(
          first_name: 'Eric', last_name: 'Santos',
          email: 'test1@test.com'))
    end
    it 'redirects to root' do
      get :google_oauth2
      expect(response).to redirect_to '/'
    end
  end

  describe 'Facebook Callback' do
    before(:each) do
      @request.env['devise.mapping'] = Devise.mappings[:user]
      @request.env['omniauth.auth'] = OmniAuth::AuthHash.new(
        provider: 'facebook', uid: '121322342341',
        info: OpenStruct.new(
          first_name: 'Eric', last_name: 'Santos',
          email: 'test2@test.com'))
    end
    it 'redirects to root' do
      get :facebook
      expect(response).to redirect_to '/'
    end
  end

  describe 'Linkedin Callback' do
    before(:each) do
      @request.env['devise.mapping'] = Devise.mappings[:user]
      @request.env['omniauth.auth'] = OmniAuth::AuthHash.new(
        provider: 'google_oauth2', uid: '121322342341',
        info: OpenStruct.new(
          first_name: 'Eric', last_name: 'Santos',
          email: 'test3@test.com'))
    end
    it 'redirects to root' do
      get :linkedin
      expect(response).to redirect_to '/'
    end
  end
end

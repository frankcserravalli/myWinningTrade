module Api
  module V1
    class FacebooksController < ApplicationController
      skip_before_filter :require_login, :only => [:authenticate]

      def authenticate
        scrambled_token = scramble_token(Time.now, create_random_string)

        @data = request.env['omniauth.auth']

        @user = User.where(:provider => @data['provider'],
                           :uid => @data['uid'])
        if @user
          # Signed In, token is sent through because the user is signed in
          render :json => { :data => @user.to_json, :ios_token => scrambled_token, :status => 200 }
        else
          # User doesn't exist, redirect to sign up page with info grabbed from facebook oauth
          render :json => { :data => @data.to_json, :status => :unauthorized }
        end
      end
    end
  end
end
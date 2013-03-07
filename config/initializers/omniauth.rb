Rails.application.config.middleware.use OmniAuth::Builder do
  provider :developer unless Rails.env.production?
  provider :facebook, '331752936918078', '6dee4f074f905e98957e9328bf4d91a3' # Frank's account
  #provider :facebook, "349566425142206", "37279cb9a30d14949d011cadc12fd1ae" # Conclave account
  provider :linkedin, '7imqhpb5d9cm', 'dUtYyIdxvrqpbdXA' # Frank's Account is better.
  provider :openid, name: 'google', identifier: 'https://www.google.com/accounts/o8/id'
end

LINKEDIN_CONFIGURATION = { :site => 'https://api.linkedin.com',
                           :authorize_path => '/uas/oauth/authenticate',
                           :request_token_path =>'/uas/oauth/requestToken?scope=rw_nus',
                           :access_token_path => '/uas/oauth/accessToken' }


OmniAuth.config.logger = Rails.logger

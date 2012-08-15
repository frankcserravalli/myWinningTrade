Rails.application.config.middleware.use OmniAuth::Builder do
  provider :developer unless Rails.env.production?
  provider :facebook, '331752936918078', '6dee4f074f905e98957e9328bf4d91a3' # Frank's account
  provider :linkedin, 'xoc3a06gsosd', '41060V6v5K38dnV4' # Frank's Account is better.
  provider :openid, name: 'google', identifier: 'https://www.google.com/accounts/o8/id'
end

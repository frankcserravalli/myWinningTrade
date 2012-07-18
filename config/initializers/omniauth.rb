Rails.application.config.middleware.use OmniAuth::Builder do
  provider :developer unless Rails.env.production?
  provider :facebook, '106132422866392', '0685df32ec9873ef96c2cf8e2f622ceb' # pascal's account
  provider :linkedin, 'e33gepa5m9nn', 'iNRTei2vCi8Mcd6L' # daniel's account
  provider :openid, name: 'google', identifier: 'https://www.google.com/accounts/o8/id'
end

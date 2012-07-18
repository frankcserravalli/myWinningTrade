Rails.application.config.middleware.use OmniAuth::Builder do
  provider :developer unless Rails.env.production?
  provider :twitter, 'YcnQioKp32tmL0Od4zcXyA', 'ZpdqL3iBDiQ9l1eZ6Kjy8U42zdDxPLxWl32fyJNjfw' # daniel's account
  provider :facebook, '106132422866392', '0685df32ec9873ef96c2cf8e2f622ceb' # pascal's account
  provider :linkedin, 'e33gepa5m9nn', 'iNRTei2vCi8Mcd6L' # daniel's account
  # provider :google_oauth2, '', '', {access_type: 'online', approval_prompt: ''}
end

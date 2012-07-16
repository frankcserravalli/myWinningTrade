Rails.application.config.middleware.use OmniAuth::Builder do
  provider :developer unless Rails.env.production?
  provider :twitter, 'YcnQioKp32tmL0Od4zcXyA', 'ZpdqL3iBDiQ9l1eZ6Kjy8U42zdDxPLxWl32fyJNjfw'
end
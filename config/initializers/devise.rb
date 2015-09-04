# Use this hook to configure devise mailer, warden hooks and so forth.
# Many of these configuration options can be set straight in your model.
# require 'openid/store/filesystem'
require 'omniauth-google-oauth2'
Devise.setup do |config|
  # The secret key used by Devise.
  config.secret_key = '26a8a2091b39a4e98a950d2bbf2425cd09b30dd979fd6e2f39c63356353d010981d276d2b6e4576ba895efed2990511acb21f6265f92fe5c13309f28d68d0d51'

  # ==> Mailer Configuration
  # Configure the e-mail address which will be shown in Devise::Mailer,
  config.mailer_sender = 'please-change-me-at-config-initializers-devise@example.com'

  # Configure the class responsible to send e-mails.
  config.mailer = 'Devise::Mailer'

  # ==> ORM configuration
  require 'devise/orm/active_record'

  # Configure which authentication keys should be case-insensitive.
  config.case_insensitive_keys = [:email]

  # Configure which authentication keys should have whitespace stripped.
  config.strip_whitespace_keys = [:email]

  # By default Devise will store the user in session.
  config.skip_session_storage = [:http_auth]

  # ==> Configuration for :database_authenticatable
  config.stretches = Rails.env.test? ? 1 : 10

  # If true, requires any email changes to be confirmed
  config.reconfirmable = true

  # Invalidates all the remember me tokens when the user signs out.
  config.expire_all_remember_me_on_sign_out = true

  # ==> Configuration for :validatable
  # Range for password length.
  config.password_length = 8..72

  # Email regex used to validate email formats.
  config.email_regexp = /\A[^@]+@[^@]+\z/

  # Time interval you can reset your password with a reset password key.
  config.reset_password_within = 6.hours

  # The default HTTP method used to sign out a resource. Default is :delete.
  config.sign_out_via = :delete

  # ==> OmniAuth
  config.omniauth :facebook, '1016457268372374', '87538fe37cff93a9984144f75e3790ec', scope: 'email'
  config.omniauth :google_oauth2, '646428424942-8egrrrpr1qp84u3a7eg2d7brdnfbe4p0.apps.googleusercontent.com', 'F8KqYp-Doz5wURcmqKt_7IFO'
  config.omniauth :linkedin, '7702lbd7elflmh', 'yejC2xLJX9nOW2wB'
end

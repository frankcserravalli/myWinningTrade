# Sets up the keys based on what environment Rails is in. Dev/Testing has the testing api keys.

#if Rails.env.development? || Rails.env.test?
#  Stripe.api_key = 'sk_test_kcF23wfgD1RtpC7BDFxPZWcs'

#  STRIPE_PUBLISHABLE_KEY = 'pk_test_aT91zOBdU6ASLRE9xr3nFih2'
#else
  Stripe.api_key = 'sk_live_DK6kT53UCpc5bESmDuih6SN8'

  STRIPE_PUBLISHABLE_KEY = 'pk_live_TmKg4iN7j3xcbZlFIvIbooPi'
#end

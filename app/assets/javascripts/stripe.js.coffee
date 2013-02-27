# This identifies your website in the createToken call below
Stripe.setPublishableKey 'pk_test_H6qjF4G8n0TONw3NkIL3wrQN '


stripeResponseHandler = (status, response) ->
  if (response.error)
    # Show the errors on the form
    $('.payment-errors').text response.error.message
    $('.submit-button').prop 'disabled', false
  else
    $form = $('.payment-form')
    # token contains id, last4, and card type
    token = response.id
    # Insert the token into the form so it gets submitted to the server
    $form.append $('<input type="hidden" name="stripeToken" />').val token
    $form.get(0).submit()

(($) ->
  $('.payment-form').submit( (event) ->

    # Disable the submit button to prevent repeated clicks
    $('.submit-button').prop 'disabled', true

    Stripe.createToken({
    number: $('.card-number').val(),
    cvc: $('.card-cvc').val(),
    exp_month: $('.card-expiry-month').val(),
    exp_year: $('.card-expiry-year').val()
    }, stripeResponseHandler)

    # Prevent the form from submitting with the default action
    return false
  )
)


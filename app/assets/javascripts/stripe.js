$(function() {
  Stripe.setPublishableKey($('meta[name="stripe-key"]').attr('content'))

  $(".payment-form").submit(function() {
    var form = this;

    $(".submit-button").attr("disabled", true);

    // Setting up card variable to be sent through form
    var card = {
      number: $(".card-number").val(),

      expMonth: $(".card-expiry-month").val(),

      expYear: $(".card-expiry-year").val(),

      cvc: $(".card-cvc").val()
    };

    Stripe.createToken(card, function(status, response) {
      if (status === 200) {
        $('#stripe_card_token').val(response.id)

        form.submit();
      } else {
        // Produce errors

        $("#stripe-error-message").text(response.error.message);
        alert(response.error.message);
        $(".submit-button").attr("disabled", false);
      }
    });

    return false;
  });
});
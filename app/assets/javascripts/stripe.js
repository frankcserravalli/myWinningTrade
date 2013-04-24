$(function() {

  // Grabbing publishable key
  Stripe.setPublishableKey('pk_live_TmKg4iN7j3xcbZlFIvIbooPi');

/* SUBSCRIPTION PAYMENTS */
/* ===================== */
  // Submiting a new subscription
  $(".submit-new-subscription-button").click(function() {

    payment_plan = $("#payment_plan").val();

    full_name = $(".full-name").val();

    if (payment_plan == "") {
      $("#stripe-error-message").text("Please select a plan.");
    } else if (full_name == ""){
      $("#stripe-error-message").text("Please enter a full name.");
    } else {
      $(".submit-new-subscription-button").attr("disabled", true);

      var form = $(".payment-form");

      // Setting up card variable to be sent through form
      var card = {
        number: $(".card-number").val(),

        expMonth: $(".card-expiry-month").val(),

        expYear: $(".card-expiry-year").val(),

        cvc: $(".card-cvc").val(),

        name: $(".full-name").val()
      };

      Stripe.createToken(card, function(status, response) {
        if (status === 200) {
          $('#stripe_card_token').val(response.id);

          $("#stripe-error-message").hide();

          form.submit();
        } else {
          // Produce errors

          $("#stripe-error-message").text(response.error.message);

          $(".submit-new-subscription-button").attr("disabled", false);
        }
      });

      return false;
    }
  });

  // Submitting for an updated subscription
  $(".submit-update-subscription-button").click(function() {

    payment_plan = $("#payment_plan").val();

    if (payment_plan == "") {
      $("#stripe-error-message").text("Please select a plan.");

      return false;
    }
  });

/* ACCOUNT BONUS PAYMENTS */
/* ====================== */
  // Submit a Account Bonuse
  $(".submit-new-subscription-button").click(function() {

    payment_plan = $("#payment_plan").val();

    full_name = $(".full-name").val();

    if (payment_plan == "") {
      $("#stripe-error-message").text("Please select a plan.");
    } else if (full_name == ""){
      $("#stripe-error-message").text("Please enter a full name.");
    } else {
      $(".submit-new-subscription-button").attr("disabled", true);

      var form = $(".payment-form");

      // Setting up card variable to be sent through form
      var card = {
        number: $(".card-number").val(),

        expMonth: $(".card-expiry-month").val(),

        expYear: $(".card-expiry-year").val(),

        cvc: $(".card-cvc").val(),

        name: $(".full-name").val()
      };

      Stripe.createToken(card, function(status, response) {
        if (status === 200) {
          $('#stripe_card_token').val(response.id);

          $("#stripe-error-message").hide();

          form.submit();
        } else {
          // Produce errors

          $("#stripe-error-message").text(response.error.message);

          $(".submit-new-subscription-button").attr("disabled", false);
        }
      });

      return false;
    }
  });

  // Submitting for an updated subscription
  $(".submit-update-subscription-button").click(function() {

    payment_plan = $("#payment_plan").val();

    if (payment_plan == "") {
      $("#stripe-error-message").text("Please select a plan.");

      return false;
    }
  });

});

$(document).ready(function() {
  $(".subscription-button").click(function() {
    value = $(this).attr("value");

    $('input[name="payment_plan"]').val(value);
  });
});
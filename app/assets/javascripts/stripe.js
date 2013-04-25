$(function() {

  // Grabbing publishable key
  //Stripe.setPublishableKey('pk_live_TmKg4iN7j3xcbZlFIvIbooPi');
  Stripe.setPublishableKey('pk_test_aT91zOBdU6ASLRE9xr3nFih2');

/* SUBSCRIPTION PAYMENTS */
/* ===================== */
  // Submiting a new subscription
  $(".submit-new-subscription-button").click(function() {

    payment_plan = $("#payment_plan").val();

    full_name = $(".full-name").val();

    // Here we check for empty fields of the user, and
    // if everything looks good we add details to card then process order
    if (payment_plan == "") {
      $("#stripe-error-message").text("Please select a plan.");
    } else if (full_name == ""){
      $("#stripe-error-message").text("Please enter a full name.");
    } else {
      $(".submit-new-subscription-button").attr("disabled", true);

      var form = $(".payment-form");

      // Setting up card details to be sent to Stripe
      var card = {
        number: $(".card-number").val(),

        expMonth: $(".card-expiry-month").val(),

        expYear: $(".card-expiry-year").val(),

        cvc: $(".card-cvc").val(),

        name: $(".full-name").val()
      };

      // Here we create the stripe token and then submit the form
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
  // Submit a Account Bonus
  $(".submit-account-bonus-button").click(function() {

    payment_plan = $("#bonus-option").val();

    full_name = $(".full-name").val();

    // Here we check for empty fields and if everything is fine we submit the form
    if (payment_plan == "") {
      $("#stripe-error-message").text("Please select a plan.");
    } else if (full_name == ""){
      $("#stripe-error-message").text("Please enter a full name.");
    } else {
      $(".submit-account-bonus-button").attr("disabled", true);

      var form = $(".payment-form");

      // Setting up card details for Stripe
      var card = {
        number: $(".card-number").val(),

        expMonth: $(".card-expiry-month").val(),

        expYear: $(".card-expiry-year").val(),

        cvc: $(".card-cvc").val(),

        name: $(".full-name").val()
      };

      // Here we create a stripe token and then submit the form with the stripe token
      Stripe.createToken(card, function(status, response) {
        if (status === 200) {
          $('#stripe_card_token').val(response.id);

          $("#stripe-error-message").hide();

          form.submit();
        } else {
          // Produce errors

          $("#stripe-error-message").text(response.error.message);

          $(".submit-account-bonus-button").attr("disabled", false);
        }
      });

      return false;
    }
  });
});

/* SUBSCRIPTION PAYMENTS */
/* ===================== */

$(document).ready(function() {
  $(".subscription-button").click(function() {
    // Here we grab then assign the user's choice in payment option
    value = $(this).attr("value");

    $('input[name="payment_plan"]').val(value);
  });
});

/* ACCOUNT BONUS PAYMENTS */
/* ====================== */

$(document).ready(function() {
  $(".select-account-bonus-button").click(function() {
    // Here we grab then assign the user's choice in bonus option
    value = $(this).attr("value");

    $('input[name="bonus_option"]').val(value);

    // Here we deselect all buttons then attach an active button class to the button the user selected
    $(".select-account-bonus-button").removeClass("selected-bonus-button").addClass("non-selected-bonus-button");

    $(this).removeClass("non-selected-bonus-button");

    $(this).addClass("selected-bonus-button");
  });
});
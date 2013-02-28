$(document).ready(function() {
  $(".subscription-button").click(function() {
    button_pressed = $(this);

    value = button_pressed.attr("value");

    $("#payment_plan").val(value);
  });
});
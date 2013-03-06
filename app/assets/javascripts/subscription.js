$(".subscription-button").click(function() {

  $(".subscription-button").removeClass("clicked-subscription-button");

  $(this).addClass("clicked-subscription-button");

});
/*
$(".subscription-button").hover(function() {

    $(".subscription-button").not(this).addClass("neutral-subscription-button");

  }, function() {

    $(".subscription-button").removeClass("neutral-subscription-button");

});
 */
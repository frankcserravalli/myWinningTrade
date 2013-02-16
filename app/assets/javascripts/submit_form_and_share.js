$('.submit-the-sell-and-share').on('click', function(e){
  // We don't want this to act as a link so cancel the link action
  e.preventDefault();

  $('#sell_form').submit();
});

$('.submit-the-buy-and-share').on('click', function(e){
  // We don't want this to act as a link so cancel the link action
  e.preventDefault();

  $('#buy_form').submit();
});
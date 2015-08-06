$( document ).ready(function() {
  var date = "Please select a date";
  $(function() {
    $( "#datepicker" ).datepicker({ 
      firstDay: 1,
      onSelect: function(dateText, object){
        console.log(dateText, object.selectedDay);
        $('.current-date').text(dateText);
        date = dateText;
      }
    });
    $('.current-date').text(date);
  });

  var counter = 0;

  $('.short-button').hide();

  $(".short-trigger").on("click", function(){
    if (counter%2 == 0){
      var url = window.location.pathname;
      var id = url.substring(url.lastIndexOf('/') + 1);
      $('#buy_form').attr('action', "/stock/".concat(id).concat("/short_sell_borrow"));
      $('.order').attr('data-type', 'order-type');
      $('.order').attr('name', 'short_sell_borrow[when]');
      $('.dial').attr('name', 'short_sell_borrow[volume]');

      $('.short-button').show();
      $('.buy-button').hide();

      $(".short-trigger").text('BUY');

      counter += 1;
    }
    else {
      var url = window.location.pathname;
      var id = url.substring(url.lastIndexOf('/') + 1);
      $('#buy_form').attr('action', "/stock/".concat(id).concat("/buy"));
      $('.order').attr('data-type', 'buy');
      $('.order').attr('name', 'buy[when]');
      $('.dial').attr('name', 'buy[volume]');

      $('.short-button').hide();
      $('.buy-button').show();

      $(".short-trigger").text('SHORT');

      counter += 1;
    }
  });

  $(".buy-trigger").on("click", function(){
    var url = window.location.pathname;
    var id = url.substring(url.lastIndexOf('/') + 1);
    $('#buy_form').attr('action', "/stock/".concat(id).concat("/buy"));
  });

  $('.market').click(function (){
    $('.future').removeClass('selected');
    $('.loss').removeClass('selected');
    $('.market').addClass('selected');

    $('.order').val('At Market')
  });

  $('.future').click(function (){
    $('.market').removeClass('selected');
    $('.loss').removeClass('selected');
    $('.future').addClass('selected');

    $('.order').val('Future')
  });

  $('.loss').click(function (){
    $('.market').removeClass('selected');
    $('.future').removeClass('selected');
    $('.loss').addClass('selected');

    $('.order').val('Stop Loss')
  });
});
$( document ).ready(function() {
  var date = "Please select a date";

  $('.sell-datepicker-button').hide();
  $('.sell-calendar').hide();
  $('.sell-picker-container').hide();
  $('.sell-timepicker-button').hide();

  $('.sell-slide').hide();

  $(function() {
    $( "#sell-datepicker" ).datepicker({ 
      firstDay: 1,
      onSelect: function(dateText, object){
        console.log(dateText, object.selectedDay);
        $('.sell-current-date').text(dateText);
        $('.sell_execute_at_1i').val(object.selectedYear);
        if (object.selectedMonth[0] == 0){
          $('#sell_execute_at_2i').val(object.selectedMonth[1]+1);
        } else{
          $('#sell_execute_at_2i').val(object.selectedMonth+1);
        }

        if (object.selectedMonth[0] == 0){
          $('#sell_execute_at_3i').val(object.selectedDay[1]);
        } else{
          $('#sell_execute_at_3i').val(object.selectedDay);
        }
        date = dateText;
      }
    });
    $('.sell-current-date').text(date);
  });

  $('.sell-datepicker-button').click(function(){
    $('.sell-calendar').slideToggle()
    $('.sell-picker-container').slideToggle()
  });

  $('.sell-timepicker-button').click(function(){
    $('.sell-calendar').slideToggle()
    $('.sell-picker-container').slideToggle()
  });

  var counter = 0;

  $('.sell-market').click(function (){
    $('.sell-future').removeClass('selected');
    $('.sell-loss').removeClass('selected');
    $('.sell-market').addClass('selected');

    $('.sell-order').val('At Market')

    $('.sell-datepicker-button').hide();
    $('.sell-calendar').hide();
    $('.sell-picker-container').hide();
    $('.sell-timepicker-button').hide();

    $('.sell-slide').hide();
  });

  $('.sell-future').click(function (){
    $('.sell-market').removeClass('selected');
    $('.sell-loss').removeClass('selected');
    $('.sell-future').addClass('selected');

    $('.sell-order').val('Future')

    $('.sell-datepicker-button').show();
    $('.sell-timepicker-button').show();

    $('.sell-slide').hide();
  });

  $('.sell-loss').click(function (){
    $('.sell-market').removeClass('selected');
    $('.sell-future').removeClass('selected');
    $('.sell-loss').addClass('selected');

    $('.sell-order').val('Stop-Loss')

    $('.sell-datepicker-button').hide();
    $('.sell-calendar').hide();
    $('.sell-picker-container').hide();
    $('.sell-timepicker-button').hide();

    $('.sell-slide').show();
  });
});
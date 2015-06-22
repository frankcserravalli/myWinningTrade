$( document ).ready(function() {
  $('.current_holdings-tab').addClass('secondary-active');
  $('.shorting').hide();
  $('.upcoming-future-transactions').hide();
  $('.pending-positions').hide();

    $('.current_holdings-tab').click(function (){
      remove_widget();
      $('.secondary-active').removeClass('secondary-active');
      $('.current_holdings-tab').addClass('secondary-active');
      $('.shorting').hide();
      $('.upcoming-future-transactions').hide();
      $('.pending-positions').hide();
      $('.current_holdings').show();
    });

    $('.shorting-tab').click(function (){
      remove_widget();
      $('.secondary-active').removeClass('secondary-active');
      $('.shorting-tab').addClass('secondary-active');
      $('.current_holdings').hide();
      $('.upcoming-future-transactions').hide();
      $('.pending-positions').hide();
      $('.shorting').show();
    });

    $('.upcoming-future-transactions-tab').click(function (){
      remove_widget();
      $('.secondary-active').removeClass('secondary-active');
      $('.upcoming-future-transactions-tab').addClass('secondary-active');
      $('.current_holdings').hide();
      $('.shorting').hide();
      $('.pending-positions').hide();
      $('.upcoming-future-transactions').show();
    });

    $('.pending-positions-tab').click(function (){
      remove_widget();
      $('.secondary-active').removeClass('secondary-active');
      $('.pending-positions-tab').addClass('secondary-active');
      $('.current_holdings').hide();
      $('.shorting').hide();
      $('.upcoming-future-transactions').hide();
      $('.pending-positions').show();
    });
});

function remove_widget(){
  $('.widget-container').removeAttr('id');
  $('.widget-container').removeAttr('id');
  var iframes = document.getElementsByTagName('iframe');
  for (var i = 0; i < iframes.length; i++) {
      iframes[i].parentNode.removeChild(iframes[i]);
  }
}
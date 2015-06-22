$( document ).ready(function() {
    //$('.portfolio').click(function (){
    //  $('.content').empty().html(".row
    //                  .span12
    //                    #chartview");
   // });
});

function show_tradingview_widget (stock_symbol){
  $('.widget-container').attr('id', 'chartview');
  var height = $('.content').height() - 20
  var width = $('.content').width() - 20

  stock_symbol = stock_symbol.toLowerCase();

  var MyWinningTrade = new Object();

  var tradingview_widget_options = {};
  tradingview_widget_options.autosize  = false;
  tradingview_widget_options.width  = width;
  tradingview_widget_options.height = height;
  tradingview_widget_options.symbol = stock_symbol;
  tradingview_widget_options.interval = 'D';
  tradingview_widget_options.toolbar_bg = '#3c5063';
  tradingview_widget_options.allow_symbol_change = false;
  tradingview_widget_options.container_id = 'chartview';
  tradingview_widget_options.save_image = false;
  tradingview_widget_options.news = true;

  new TradingView.widget(tradingview_widget_options);
}
$( document ).ready(function() {
    //$('.portfolio').click(function (){
    //  $('.content').empty().html(".row
    //                  .span12
    //                    #chartview");
   // });
});

function show_stock_info (stock_symbol, name, shares, cost, percent){
  var div = document.createElement('div');

  div.className = 'stock-info';

  div.innerHTML = '<ul>\
                    <li><span class="header">'.concat(stock_symbol).concat('</span><br /><span class="subheader black">'.concat(name).concat('</span></li>\
                    <li><span class="header">STOCK IN PORTFOLIO</span><br /><span class="subheader green">'.concat(shares).concat('/ 8,167.34 $</span></li>\
                    <li><span class="header">MONTHLY GAIN / LOSS</span><br /><span class="subheader red">'.concat(cost).concat('/').concat(percent).concat('</span></li>\
                    <li class="button">BUY</li>\
                    <li class="button"><span>SELL</span></li>\
                  </ul>'))));

  var content = document.getElementById('content');
  content.insertBefore(div, content.firstChild);
}

function show_tradingview_widget (stock_symbol, name, shares, cost, percent){
  $('.first').hide();
  $('.second').hide();
  $('.third').hide();
  $('.fourth').hide();
  $('.fifth').hide();
  $('.sixth').hide();

  show_stock_info(stock_symbol, name, shares, cost, percent);

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
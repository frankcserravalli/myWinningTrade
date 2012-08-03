App.StockTrendView = Em.View.extend
  templateName: 'stock_trend'
  classNames: ['stock-trend']
  classNameBindings: ['trendingClass']
  trendingClass: ( ->
    'trending-' + @getPath('stock.trend_direction')
  ).property('stock.trend_direction')

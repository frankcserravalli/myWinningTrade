App.GraphView = Em.View.extend
  templateName: 'graph'
  stocksBinding: 'controller.stocks'
  currentPeriodBinding: 'controller.currentPeriod'

  stocksLastUpdatedAtDidChange: ( ->
    console.log 'last updated at changed'
    @buildGraph()
  ).observes('App.router.stockListController.lastUpdatedAt')


  seriesData: (->
    palette = new Rickshaw.Color.Palette({ scheme: 'classic9' })
    _.map @get('stocks'), (item) =>
      palette.color()
      {
        data: _.map item.price_history[@get 'currentPeriod'], (quote) ->
          { x: quote[0], y: quote[1] }
        name: item.name
        color: palette.color()
      }
  ).property('stocks.@each', 'currentPeriod')

  buildGraph: ->
    $('.chart',@$()).empty()
    @graph = new Rickshaw.Graph
      element: $('.chart',@$()).get(0)
      width: 620
      height: 230
      renderer: 'line'
      stroke: true
      series: @get('seriesData') # depending on graph view type
    @graph.render()
    @details = new Rickshaw.Graph.StockHoverDetail({ graph: @graph })
    ticksTreatment = 'glow'
    (new Rickshaw.Graph.Axis.Time({ graph: @graph, ticksTreatment: ticksTreatment })).render()
    (new Rickshaw.Graph.Axis.Y({ graph: @graph, ticksTreatment: ticksTreatment })).render()

  didInsertElement: ->
    @addObserver 'seriesData', ->
      @buildGraph()

App.GraphView = Em.View.extend
  templateName: 'graph_view'
  stocksBinding: 'App.router.stockListController.loadedStocks'

  seriesData: (->
    palette = new Rickshaw.Color.Palette({ scheme: 'classic9' })
    _.map @get('stocks'), (item) ->
      palette.color()
      {
        data: _.map item.price_history.historical, (quote) ->
          { x: quote[0], y: quote[1] }
        name: item.name
        color: palette.color()
      }
  ).property('stocks')

  buildGraph: ->
    console.log 'building graph'
    if @graph
      @graph.series = new Rickshaw.Series @get('seriesData')
      @graph.series.active = ->
        @filter (s) ->
          !s.disabled

      @graph.update()
    else
      @graph = new Rickshaw.Graph
        element: $('.chart',@$()).get(0)
        width: 620
        height: 230
        renderer: 'line'
        stroke: true
        series: @get('seriesData') # depending on graph view type
      @graph.render()
      hoverDetail = new Rickshaw.Graph.StockHoverDetail({ graph: @graph })
      ticksTreatment = 'glow'
      (new Rickshaw.Graph.Axis.Time({ graph: @graph, ticksTreatment: ticksTreatment })).render()
      (new Rickshaw.Graph.Axis.Y({ graph: @graph, ticksTreatment: ticksTreatment })).render()

  seriesDataDidChange: (->
    @buildGraph()
  ).observes('seriesData')

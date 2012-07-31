App.GraphView = Em.View.extend
  templateName: 'graph_view'
  seriesData: []

  timePeriod: 'intraday'
  viewHistorical: ->
    @set 'timePeriod', 'historical'

  viewIntraday: ->
    @set 'timePeriod', 'intraday'

  isHistorical: (->
    @get('timePeriod') == 'historical'
  ).property('timePeriod')


  buildGraph: ->
    console.log 'no graph, building'
    console.log(@seriesData)

    @graph = new Rickshaw.Graph
      element: $('.chart',@$()).get(0)
      width: 940
      height: 500
      renderer: 'line'
      stroke: true
      series: @seriesData
    @graph.render()
    hoverDetail = new Rickshaw.Graph.StockHoverDetail({ graph: @graph })
    ticksTreatment = 'glow'
    (new Rickshaw.Graph.Axis.Time({ graph: @graph, ticksTreatment: ticksTreatment })).render()
    (new Rickshaw.Graph.Axis.Y({ graph: @graph, ticksTreatment: ticksTreatment })).render()

  #stocks
  didInsertElement: (element) ->
    @addObserver 'loadedStocks', ->
      palette = new Rickshaw.Color.Palette( { scheme: 'classic9' } )
      @seriesData = _.map @get('loadedStocks'), (item) ->
        palette.color()
        {
          data: _.map item.price_history.historical, (quote) ->
            { x: quote[0], y: quote[1] }
          name: item.name
          color: palette.color()
        }

      $('.chart',@$()).empty() if @graph
      @buildGraph()

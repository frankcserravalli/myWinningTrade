App.GraphView = Em.View.extend
  templateName: 'graph'
  stocksBinding: 'controller.stocks'
  currentPeriodBinding: 'controller.currentPeriod'

  stocksLastUpdatedAtDidChange: ( ->
    console.log 'rebuilding graph'
    # TODO make this only rebuild if current view is live? or just update graph..
    @buildGraph()
  ).observes('App.router.stockListController.lastUpdatedAt')


  seriesData: (->
    palette = new Rickshaw.Color.Palette({ scheme: 'classic9' })
    seriesData = new Object
    current_period = @get 'currentPeriod'
    series_minimums = []
    series_maximums = []

    all_times = _.intersection.apply(_, _.map(@get('stocks'), (stock) ->
      _.map stock.price_history[current_period], (quote) ->
        quote[0]
    ))

    seriesData.quoteList = _.map @get('stocks'), (stock) =>
      relevant_quotes = _.filter stock.price_history[current_period], (quote) ->
        detected = _.detect all_times, (time) ->
          time == quote[0]
        detected?

      if relevant_quotes.length > 0
        series_minimums.push (_.min relevant_quotes, (quote) ->
          quote[1])[1]

        series_maximums.push (_.max relevant_quotes, (quote) ->
          quote[1])[1]

      palette.color()
      {
        data: _.map relevant_quotes, (quote) ->
          { x: quote[0]-moment().zone()*60, y: quote[1] }
        name: stock.name
        color: palette.color()
      }

    seriesData.minimum = _.min(series_minimums)
    seriesData.maximum = _.max(series_maximums)
    seriesData.deltaRange = seriesData.maximum - seriesData.minimum
    seriesData

  ).property('stocks.@each', 'currentPeriod')

  buildGraph: ->
    $('.chart',@$()).empty()
    seriesData = @get('seriesData')

    @graph = new Rickshaw.Graph
      element: $('.chart',@$()).get(0)
      width: 620
      height: 230
      min: seriesData.minimum - seriesData.deltaRange*0.3
      max: seriesData.maximum + seriesData.deltaRange*0.3
      renderer: 'line'
      stroke: true
      series: seriesData.quoteList # depending on graph view type
    @graph.render()
    @details = new Rickshaw.Graph.StockHoverDetail({ graph: @graph })
    ticksTreatment = 'glow'
    (new Rickshaw.Graph.Axis.Time({ graph: @graph, ticksTreatment: ticksTreatment })).render()
    (new Rickshaw.Graph.Axis.Y({ graph: @graph, ticksTreatment: ticksTreatment })).render()
    @graph.currentPeriod = @get 'currentPeriod'


    $('.slider',@$()).slider('destroy')
    delete @graph.slider
    if @get('currentPeriod') == 'historical'
      @graph.slider = new SnappySlider({ graph: @graph, element: $('.slider',@$()), view: @ });

  didInsertElement: ->
    @addObserver 'seriesData', ->
      @buildGraph()

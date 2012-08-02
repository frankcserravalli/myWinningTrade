class @SnappySlider
  constructor: (args) ->
    @element = args.element
    @graph = args.graph
    @view = args.view

    unless @view.get('sliderPos')
      # set slider to midpoint unless there is a stored value
      @view.set('sliderPos',@graph.series[0].data[(@graph.series[0].data.length/2)].x)

    sliderDidChange = (event, ui) =>
      # save new slider pos
      @view.set 'sliderPos', ui.value

      x_start = ui.value
      x_end = @graph.dataDomain()[1]

      @graph.window.xMin = x_start
      @graph.window.xMax = x_end

      y_mins = _.map @graph.series, (series) ->
        relevant_series_samples = _.filter series.data, (elem) ->
          x_start <= elem.x <= x_end
        _.min(_.pluck(relevant_series_samples,'y'))
      y_min = _.min(y_mins)

      y_maxs = _.map @graph.series, (series) ->
        relevant_series_samples = _.filter series.data, (elem) ->
          x_start <= elem.x <= x_end
        _.max(_.pluck(relevant_series_samples,'y'))
      y_max = _.max(y_maxs)

      delta = Math.round((y_max-y_min)*0.1);

      @graph.min = y_min-delta
      @graph.max = y_max+delta
      @graph.update()

    $ =>
      $(@element).slider
        range: 'max'
        min: @graph.dataDomain()[0]
        max: @graph.series[0].data.slice(-8).shift().x
        value: @graph.dataDomain()[0]
        change: sliderDidChange
        slide: sliderDidChange

    @element[0].style.width = @graph.width + 'px'
    $(@element).slider('value', @view.get('sliderPos'))


class @SnappySlider
  constructor: (args) ->
    @element = args.element
    @graph = args.graph
    $ =>
      $(@element).slider({
        range: false,
        min: @graph.dataDomain()[0],
        max: @graph.dataDomain()[1],
        values: [ @graph.dataDomain()[0], @graph.dataDomain()[1] ],
        slide: (event, ui) =>
          x_start = ui.values[0]
          x_end = ui.values[1]

          @graph.window.xMin = x_start
          @graph.window.xMax = x_end

          y_mins = _.map @graph.series, (series) ->
            relevant_series_samples = _.filter series.data, (elem) ->
              x_start <= elem.x <= x_end
            _.min(_.pluck(relevant_series_samples,'y'))
          y_min = _.min(y_mins)

          @graph.min = y_min
          @graph.update()
      })

    @element[0].style.width = @graph.width + 'px'

    @graph.onUpdate =>
      values = $(@element).slider('option', 'values')
      $(@element).slider('option', 'min', @graph.dataDomain()[0]);
      $(@element).slider('option', 'max', @graph.dataDomain()[1]);

      values[0] = @graph.dataDomain()[0] unless @graph.window.xMin?
      values[1] = graph.dataDomain()[1] unless @graph.window.xMax?
      $(@element).slider('option', 'values', values)

window.build_stock_graph = (stock_name, data) ->
  graph = new Rickshaw.Graph({
    element: document.getElementById("chart"),
    width: 770,
    height: 500,
    renderer: 'line',
    stroke: true,
    series: [
      {
        color: 'steelblue',
        data: data,
        name: stock_name
      }
    ]
  })

  slider = new SnappySlider({ graph: graph, element: $('#slider') })
  hoverDetail = new Rickshaw.Graph.HoverDetail({ graph: graph })

  ticksTreatment = 'glow'
  xAxis = new Rickshaw.Graph.Axis.Time({ graph: graph, ticksTreatment: ticksTreatment })
  yAxis = new Rickshaw.Graph.Axis.Y({ graph: graph, ticksTreatment: ticksTreatment })

  graph.render()
  xAxis.render()
  yAxis.render()

  graph

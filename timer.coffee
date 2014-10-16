class Dashing.Timer extends Dashing.Widget

  displayError:(msg) ->
    $(@node).find(".error").show()
    $(@node).find(".error").html(msg)
  displayMissingDependency:(name,url) ->
    error_html = "<h1>Missing #{name}</h1><p>Download <a href='#{url}'>#{name}</a> and place it in the <span class='highlighted'>assets/javascripts</span> folder"
    @displayError(error_html)

  ready: ->

    
    @displayMissingDependency("moment.js","http://momentjs.com/downloads/moment.min.js") if (!window.moment)
    @displayMissingDependency("lodash.js","https://raw.githubusercontent.com/lodash/lodash/2.4.1/dist/lodash.min.js") if (!window._)
    @displayMissingDependency("jQuery Sparkline","http://omnipotent.net/jquery.sparkline/#s-about") if (!$.fn.sparkline)

    if @get('debug')
      @debug = (@get('debug'))
    else
      @debug = false



    # use the data-unit property in the widget tag to indicate the unit to display (Default:ms)
    if typeof @get('unit') isnt "undefined"
      @unit = (@get('unit'))
    else
      @unit = "ms"

    # use the graphite_host property in the widget tag to indicate the graphite host (Default:our P2 graphite host)
    if @get('graphite_host')
      @graphite_host = (@get('graphite_host'))
    else
      @graphite_host = "http://graphite"

    $n = $(@node)

    # The widget looks at 24 hours worth of data in 10 minutes increment and compares it to the same day a week ago
    targets= ["summarize(#{@get('metric')},'10min','avg')",
    "timeShift(summarize(#{@get('metric')},'10min','avg'),'7d')"]

    console.dir targets if @debug

    @encoded_target = _.reduce(targets, (memo,target,key) ->
      memo += "&target=#{target}"
    ,"")

    if @get('interval')
      interval = parseInt(@get('interval'))
    else
      interval = 60000

    self = this

    console.dir self if @debug

    setInterval ->
      self.updateGraph()
    , interval
    @updateGraph()

    setInterval ->
      self.updateSparkline()
    , interval*100

    @updateSparkline()

  updateGraph: ->

    graph_data_url = "#{@graphite_host}/render?format=json#{@encoded_target}"
    console.log graph_data_url if @debug
    $.getJSON graph_data_url,
      from: '-1d'
      until: 'now',
      renderResults.bind(@)

  updateSparkline: ->
    metric = @get('metric')
    target = "&target=summarize(#{metric},'8h','avg')"
    graph_data_url = "#{@graphite_host}/render?format=json#{target}"

    console.log "Month worth of data in 8 hours increments for #{metric} grabbed from: #{graph_data_url}" if @debug

    $.getJSON graph_data_url,
      from: '-30d'
      until: 'now',
      renderSparkline.bind(@)

  renderSparkline = (data) ->
    console.dir(data) if @debug
    dataset = _.compact(roundUpArrayValues(removeTimestampFromTuple(data[0].datapoints)))

    console.log(dataset.length)
    if dataset.length>1
      $(@node).find(".sparkline-chart").sparkline(dataset, {
      type: 'line',
      chartRangeMin: 0,
      drawNormalOnTop: true,
      normalRangeMax: 3000,
      width:'12em',
      normalRangeColor: '#336699'})
    else
      $(@node).find(".sparkline").hide()

  renderResults = (data) ->
    dataAverage = Math.floor(array_values_average(_.compact(removeTimestampFromTuple(data[0].datapoints))))
    dataAverage_minus1w = Math.floor(array_values_average(_.compact(removeTimestampFromTuple(data[1].datapoints))))
    change_rate = Math.floor(dataAverage/dataAverage_minus1w*100) - 100

    $(@node).find(".change-rate i").removeClass("icon-arrow-up").removeClass("icon-arrow-down")

    if isNaN change_rate
      change_rate = "No data for -7d"
      $(@node).find(".change-rate").css("font-size","1em")
      $(@node).find(".change-rate").css("line-height","40px")

    else if change_rate>0
      $(@node).find(".change-rate").css("color","red")
      change_rate=change_rate+"%"
      $(@node).find(".change-rate i").addClass("icon-arrow-up")

    else if change_rate==0
      $(@node).find(".change-rate").css("color","white")
      change_rate="no change"
      $(@node).find(".change-rate").css("font-size","1em")
      $(@node).find(".change-rate").css("line-height","40px")
    else
      $(@node).find(".change-rate").css("color","green")
      change_rate=change_rate+"%"
      $(@node).find(".change-rate i").addClass("icon-arrow-down")

    unit = @unit
    if isNaN dataAverage
      $(@node).find(".value").text("N/A").fadeOut().fadeIn()
    else
      $(@node).find(".value").html("#{dataAverage}<span style='font-size:.3em;'>#{unit}</span>").fadeOut().fadeIn()
    $(@node).find(".change-rate span").text("#{change_rate}")
    $(@node).find(".change-rate span").fadeOut().fadeIn()
    $(@node).find(".updated-at").text(moment().format('MMMM Do YYYY, h:mmA')).fadeOut().fadeIn()

    return

  removeTimestampFromTuple = (arr) ->
    _.map(arr, (num) -> num[0])
  roundUpArrayValues = (arr) ->
    _.map(arr, (num) -> Math.floor(num))

  array_values_average = (arr) ->
    _.reduce(arr, (memo, num) ->
      memo + num
    , 0) / arr.length



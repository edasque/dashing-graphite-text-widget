class Dashing.Timer extends Dashing.Widget

  ready: ->

    # use the data-unit property in the widget tag to indicate the unit to display (Default:ms)
    if @get('unit')
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
    targets= ["smartSummarize(#{@get('timer')},'10min','avg')",
    "timeShift(smartSummarize(#{@get('timer')},'10min','avg'),'7d')"]
    
    @encoded_target = _.reduce(targets, (memo,target,key) ->
      memo += "&target=#{target}"
    ,"")

    if @get('interval')
      interval = parseInt(@get('interval'))
    else
      interval = 60000

    self = this
    setInterval ->
      self.updateGraph()
    , interval
    @updateGraph()

    setInterval ->
      self.updateSparkline()
    , interval*100

    @updateSparkline()

  updateGraph: ->
    $.getJSON "#{@graphite_host}/render?format=json#{@encoded_target}",
      from: '-1d'
      until: 'now',
      renderResults.bind(@)

  updateSparkline: ->
    timer = @get('timer')
    target = "&target=smartSummarize(#{timer},'8h','avg')"
    $.getJSON "#{@graphite_host}/render?format=json#{target}",
      from: '-30d'
      until: 'now',
      renderSparkline.bind(@)

  renderSparkline = (data) ->
    $(@node).find(".sparkline").sparkline(_.compact(roundUpArrayValues(removeTimestampFromTuple(data[0].datapoints))), {
    type: 'line',
    chartRangeMin: 0,
    drawNormalOnTop: true,
    normalRangeMax: 3000,
    normalRangeColor: '#336699'})

    
  renderResults = (data) ->
    dataAverage = Math.floor(array_values_average(_.compact(removeTimestampFromTuple(data[0].datapoints))))
    dataAverage_minus1w = Math.floor(array_values_average(_.compact(removeTimestampFromTuple(data[1].datapoints))))
    change_rate = Math.floor(dataAverage/dataAverage_minus1w*100) - 100

    $(@node).find(".change-rate i").removeClass("icon-arrow-up").removeClass("icon-arrow-down")


    if isNaN change_rate
      change_rate = "No previous history"
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
    $(@node).find(".value").text("#{dataAverage}#{unit}")
    $(@node).find(".change-rate span").text("#{change_rate}")
    $(@node).find(".updated-at").text(moment().format('MMMM Do YYYY, h:mmA'))

    return

  removeTimestampFromTuple = (arr) ->
    _.map(arr, (num) -> num[0])
  roundUpArrayValues = (arr) ->
    _.map(arr, (num) -> Math.floor(num))

  array_values_average = (arr) ->
    _.reduce(arr, (memo, num) ->
      memo + num
    , 0) / arr.length



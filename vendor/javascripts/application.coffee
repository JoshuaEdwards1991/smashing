Batman.Filters.PrettyNumber = (num) ->
  num.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ",") unless isNaN(num)

Batman.Filters.dashize = (str) ->
  dashes_rx1 = /([A-Z]+)([A-Z][a-z])/g;
  dashes_rx2 = /([a-z\d])([A-Z])/g;

  return str.replace(dashes_rx1, '$1_$2').replace(dashes_rx2, '$1_$2').replace('_', '-').toLowerCase();

class window.AllTheThings extends Batman.App
  @root -> 

Batman.Property.EasingSetter =
  get: Batman.Property.defaultAccessor.get
  set: (k, to) ->
    if isNaN(to)
      @[k] = to
    else
      timer = "interval_#{k}"
      num = if !isNaN(@[k]) then @[k] else 0
      unless @[timer] || num == to
        up = to > num
        num_interval = Math.abs(num - to) / 90
        @[timer] = 
          setInterval =>
            num = if up then Math.ceil(num+num_interval) else Math.floor(num-num_interval)
            if (up && num > to) || (!up && num < to)
              num = to
              clearInterval(@[timer])
              @[timer] = null
              delete @[timer]
            @[k] = num
            @set k, to
      @[k] = num    

AllTheThings.widgets = widgets = {}
AllTheThings.lastEvents = lastEvents = {}

source = new EventSource('/events')
source.addEventListener 'open', (e)->
  console.log("Connection opened")

source.addEventListener 'error', (e)->
  console.log("Connection error")
  if (e.readyState == EventSource.CLOSED)
    console.log("Connection closed")

source.addEventListener 'message', (e) =>
  data = JSON.parse(e.data)
  lastEvents[data.id] = data
  if widgets[data.id]?.length > 0
    for widget in widgets[data.id]
      widget.onData(data)


$(document).ready ->
  AllTheThings.run()
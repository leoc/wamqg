class WamqgClient
  url: 'ws://127.0.0.1:8080'
  callbacks: {}

  constructor: ->
    @socket = new WebSocket(@url)
    @socket.onmessage = (message) =>
      json = JSON.parse message.data
      headers = json.headers
      payload = JSON.parse json.payload
      unless @callbacks[json.routing_key] is undefined
        callback(headers, payload) for callback in @callbacks[json.routing_key]

  bind: (key, callback) =>
    @socket.send "bind #{key}"
    @callbacks[key] ||= []
    @callbacks[key].push callback

window.wamqg = new WamqgClient()

class Backbone.WamqgModel extends Backbone.Model
  initialize: ->
    window.wamqg.bind @wamqg_binding, (headers, payload) =>
      @set @parse(payload)

class Backbone.WamqgCollection extends Backbone.Collection
  initialize: ->
    window.wamqg.bind @wamqg_binding, (headers, payload) =>
      model = @get(payload['id'])
      if model
        model.set model.parse(payload), silent: true
        if (typeof(@wamqg_visible_if) == 'undefined') or @wamqg_visible_if(model, headers)
          model.change()
          @sort()
        else
          @remove model, silent: true
          @trigger 'reset'
      else
        @add payload, parse: true, silent: true
        @sort()

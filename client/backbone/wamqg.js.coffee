class window.Wamqg extends Backbone.Model
  callbacks: {}
  outbox: []

  defaults:
    status: WebSocket.CLOSED
    url: "ws://localhost:8080"

  connect: =>
    @socket = new WebSocket(@get "url")
    @socket.onopen = =>
      @set status: @socket.readyState
      for key, value of @callbacks
        @socket.send "bind #{key}"
      @process_outbox()
    @socket.onmessage = (message) =>
      json = JSON.parse message.data
      headers = json.headers
      payload = JSON.parse json.payload
      unless @callbacks[json.routing_key] is undefined
        callback(headers, payload) for callback in @callbacks[json.routing_key]
    @socket.onclose = =>
      @set status: @socket.readyState

  bind_to_amqp: (key, callback) =>
    if @socket and @socket.readyState is WebSocket.OPEN
      @socket.send "bind #{key}"
    @callbacks[key] ||= []
    @callbacks[key].push callback

  publish: (key, payload) =>
    @outbox.push "publish #{key} #{payload}"
    @process_outbox()

  process_outbox: =>
    if @socket and @socket.readyState is WebSocket.OPEN
      while @outbox.length > 0
        message = @outbox.shift()
        @socket.send message

class Backbone.WamqgModel extends Backbone.Model
  initialize: (wamqg = undefined) ->
    if wamqg is undefined
      @wamqg = window.wamqg
    else
      @wamqg = wamqg
    if @wamqg_binding
      @wamqg.bind_to_amqp @wamqg_binding, (headers, payload) =>
        @set @parse(payload)

  publish: (key, payload) =>
    @wamqg.publish(key, payload)

class Backbone.WamqgCollection extends Backbone.Collection
  wamqg_primary_key: 'id'

  initialize: (wamqg = undefined) ->
    if wamqg is undefined
      @wamqg = window.wamqg
    else
      @wamqg = wamqg
    @wamqg.bind_to_amqp @wamqg_binding, (headers, payload) =>
      model = @find (item) =>
        item.get(@wamqg_primary_key) is payload[@wamqg_primary_key]
      if model
        rank_before = @comparator(model)
        model.set model.parse(payload), silent: true
        if (typeof(@wamqg_visible_if) == 'undefined') or @wamqg_visible_if(model, headers, payload)
          model.change()
          if @comparator(model) != rank_before
            @sort()
        else
          @remove model, silent: true
          @trigger 'reset'
      else
        @add payload, parse: true, silent: true
        @sort()

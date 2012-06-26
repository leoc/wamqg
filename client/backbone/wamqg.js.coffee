class WamqgClient
  url: 'ws://127.0.0.1:8080'
  callbacks: {}

  constructor: ->
    @socket = new WebSocket(@url)
    @socket.onmessage = (message) =>
      json = JSON.parse message.data
      payload = JSON.parse json.payload
      unless @callbacks[json.routing_key] is undefined
        callback(payload) for callback in @callbacks[json.routing_key]

  bind: (key, callback) =>
    @socket.send "bind #{key}"
    @callbacks[key] ||= []
    @callbacks[key].push callback

window.wamqg = new WamqgClient()

class Backbone.WamqgModel extends Backbone.Model
  wamqg_bind: (key, callback) =>
    window.wamqg.bind key, (data) =>
      @set @parse(data)

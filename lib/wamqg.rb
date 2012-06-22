require 'json'

class WAMQG
  class << self
    def start
      @queues = {}

      EventMachine::WebSocket.start(:host => "0.0.0.0", :port => 8080) do |ws|
        ws.onopen do
          @queues[ws] = CHANNEL.queue('', auto_delete: true)
          @queues[ws].subscribe do |headers,payload|
            puts "message! #{payload}"
            _message = {
              routing_key: headers.routing_key,
              payload: payload
            }
            ws.send _message.to_json
          end
        end

        ws.onclose do
          @queues.delete(ws).delete
        end

        ws.onmessage { |message|
          puts "Received message: #{message}"
          if message =~ /^bind (.*)/
            routing_key = $1
            @queues[ws].bind(EXCHANGE, routing_key: routing_key)
          end
        }
      end
    end

    def stop
      EM.stop
    end

  end
end

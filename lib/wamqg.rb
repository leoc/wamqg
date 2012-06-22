require 'json'

class WAMQG
  class << self

    def start
      EventMachine::WebSocket.start(:host => "0.0.0.0", :port => 8080) do |ws|
        ws.onopen do
          puts "WebSocket connection open: #{ws.inspect}"
        end

        ws.onclose do
          puts "Connection closed"
        end

        ws.onmessage { |message|
          puts "Received message: #{message}"
          if message =~ /^bind (.*)/
            routing_key = $1
            CHANNEL.queue('wamqg', auto_delete: true).bind(EXCHANGE, routing_key: routing_key).subscribe do |headers,payload|
              _message = {
                routing_key: headers.routing_key,
                payload: payload
              }
              ws.send _message.to_json
            end
          end
        }
      end
    end

    def stop
      EM.stop
    end

  end
end

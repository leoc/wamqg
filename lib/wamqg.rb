require 'json'

class WAMQG
  class << self
    def start
      @queues = {}

      EventMachine::WebSocket.start(:host => "0.0.0.0", :port => 8080) do |ws|
        ws.onopen do
          @queues[ws] = []
        end

        ws.onclose do
          puts "closing queues."
          @queues.delete(ws).each do |queue|
            queue.delete
          end
        end

        ws.onmessage { |message|
          puts "Received message: #{message}"
          if message =~ /^bind (.*)/
            routing_key = $1
            @queues[ws] << CHANNEL.queue do |queue|
              queue.subscribe do |headers,payload|
                puts "message! #{payload}"
                _message = {
                  routing_key: routing_key,
                  payload: payload
                }
                ws.send _message.to_json
              end
              queue.bind(EXCHANGE, routing_key: routing_key)
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

require 'socket'

module RBDB
    class Server

        OPTIONS = {
            port: 1121
        }

        def initialize
            @server = TCPServer.new OPTIONS[:port]

            trap("INT") { shutdown }
            start!
        end

        def start!
            puts "RBDB server started on port #{OPTIONS[:port]}."

            loop do
                client = @server.accept
                @result = client.gets
                client.puts @result
                client.close
            end
        end

        def shutdown
            puts "\nRBDB server shutting down."
            exit!
        end

    end
end
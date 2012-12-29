require 'socket'
require 'rbdb/db/db'

module RBDB
    module DB
        class Server

            OPTIONS = {
                port: 1121
            }

            def initialize
                @server = TCPServer.new OPTIONS[:port]
                @db = DB.new

                trap("INT") { shutdown }
                start!
            end

            def start!
                puts "RBDB server started on port #{OPTIONS[:port]}."

                loop do
                    client = @server.accept
                    request = client.gets

                    response = @db.process(request)

                    client.puts response
                    client.close
                end
            end

            def shutdown
                puts "\nRBDB server shutting down."
                exit!
            end

        end
    end
end
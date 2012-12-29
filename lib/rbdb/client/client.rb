require 'bson'

module RBDB
    module Client
        class Client

            OPTIONS = {
                binding: TOPLEVEL_BINDING,
                host: 'localhost',
                port: 1121
            }

            OP_CODES = {
                insert: 0,
                delete: 1,
                query: 2
            }

            def initialize
                @binding = binding()
                @data = Array.new
                @id = 1
            end

            def insert(obj)
                validate(obj)
                setup_connection
                headers = generate_headers(__method__)
                body = {
                    documents: obj
                }
                send(body, headers)
            end

            def delete(obj)
                validate(obj)
                setup_connection
                headers = generate_headers(__method__)
            end

            def query(obj)
                validate(obj)
                setup_connection
                headers = generate_headers(__method__)
            end

            private

                def setup_connection
                    begin
                        @connection = TCPSocket.new(OPTIONS[:host], OPTIONS[:port])
                    rescue Exception => e
                        puts "there was an error connecting to the server"
                        puts e
                        exit!
                    end
                end

                def validate(obj)
                    obj = obj.is_a Array ? obj : [obj]
                    obj.each do |o|
                        raise BadTypeError unless o.is_a? Hash
                    end
                end

                def generate_headers(method)
                    {
                        request_id: @id +=1,
                        op_code: OP_CODES[method]
                    }
                end

                def send(body, headers)
                    request = BSON.serialize({body: body, headers: headers})
                    @connection.puts(request)
                    @connection.read
                end
        end

        class BadTypeError < ArgumentError

            def to_s
                "All operations must use the Hash data type."
            end
        end
    end
end
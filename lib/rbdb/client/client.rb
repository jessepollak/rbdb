require 'json'

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
                query: 2,
                handshake: 100
            }

            def initialize
                @binding = binding()
                @data = Array.new
                @id = 1
                @collection = nil
                @collections = []

                handshake
            end

            def insert(obj, collection=@collection)
                @collection = nil

                obj = validate(obj, array: true)
                setup_connection
                headers = generate_headers(__method__, collection)
                body = {
                    documents: obj
                }
                send(body, headers)
            end

            def delete(obj, collection=@collection)
                @collection = nil

                validate(obj)
                setup_connection
                headers = generate_headers(__method__, collection)
            end

            def query(obj, collection=@collection)
                @collection = nil

                validate(obj)
                setup_connection
                headers = generate_headers(__method__, collection)
                body = {
                    query: obj
                }
                send(body, headers)
            end

            def handshake
                setup_connection
                headers = generate_headers(__method__)
                body = {}

                response = JSON.parse(send(body, headers))

                @collections = response
            end

            def method_missing(method, *args, &block)
                if @collections.member? method.to_s
                    @collection = method
                    self
                else
                    super
                end
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

                def validate(obj, opts = {})
                    if opts[:array]
                        obj = (obj.is_a? Array) ? obj : [obj]

                        obj.each do |o|
                            raise BadTypeError unless o.is_a? Hash
                        end
                    else
                        raise BadTypeError unless obj.is_a? Hash
                    end
                    obj
                end

                def generate_headers(method, collection=nil)
                    {
                        request_id: @id +=1,
                        op_code: OP_CODES[method],
                        collection: collection
                    }
                end

                def send(body, headers)
                    request = {body: body, headers: headers}.to_json
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
module RBDB
    class DB

        OPTIONS = {
            binding: TOPLEVEL_BINDING,
            host: 'localhost',
            port: 1121
        }

        OP_CODES = {
            insert: 1,
            delete: 2,
            query: 3
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
            puts headers
        end

        def delete(obj)
            validate(obj)
            setup_connection
            return !@data.delete(obj).nil?
        end

        def query(obj)
            validate(obj)
            setup_connection
            @data
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
                unless obj.is_a? Hash
                    raise BadTypeError
                end
            end

            def generate_headers(method)
                {
                    request_id: @id +=1,
                    op_code: OP_CODES[method]
                }
            end
    end

    class BadTypeError < ArgumentError

        def to_s
            "All operations must use the Hash data type."
        end
    end
end
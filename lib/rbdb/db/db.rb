require 'json'
require 'fileutils'

module RBDB
    module DB
        class DB
            OPTIONS = {
                path: 'data/rbdb/'
            }

            OP_CODES = {
                1 => :insert,
                2 => :delete,
                3 => :query,
                100 => :handshake
            }

            def initialize
                @path = OPTIONS[:path]
                @collections = {}

                if !File.exists? @path
                    FileUtils.mkdir_p @path
                else
                    load_collections
                end
            end

            def process(request)
                request = JSON.parse(request)

                self.send(OP_CODES[request['headers']['op_code']], request)
            end

            def load_collections
                Dir.glob(@path + '*.ns') do |coll|
                    name = name_regex.match(coll)[1]
                    @collections[name] = Collection.new(name)
                end
            end

            def collections
                @collections
            end

            def name_regex
                /#{@path}(.*).ns/
            end

            def insert(request)
                coll = find_or_create_collection(request['headers']['collection'])
                coll.insert(request)
            end

            def delete(request)
                raise NoCollectionError unless coll = @collections[request['headers']['collection']]
                puts "DELETE: #{request}"
            end

            def query(request)
                raise NoCollectionError unless coll = @collections[request['headers']['collection']]
                coll.query(request)
            end

            def handshake(request)
            end

            def find_or_create_collection(name)
                if coll = @collections[name]
                    coll
                else
                    coll = Collection.new(name)
                    @collections[name] = coll
                end
            end

        end

        class NoCollectionError < StandardError
            def to_s
                "The collection must already exist to query or delete."
            end
        end
    end
end
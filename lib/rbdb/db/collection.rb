module RBDB
    module DB
        class Collection

            attr_reader :name, :indexes

            OPTIONS = {
                path: 'data/rbdb/'
            }

            def initialize(name)
                @path = OPTIONS[:path]
                @name = name

                file_path = @path + name + '.ns'
                if File.exists? file_path
                    @file = File.open(file_path, 'rb+')
                    load_collection
                else
                    @file = File.open(file_path, 'ab+')
                end

                load_indexes
            end

            def insert(request)
                docs = request[:body][:documents]
                docs.each do |doc|
                    puts doc
                    d = Document.new(doc, @file)
                    @indexes[:_id].insert(d)
                end
            end

            def delete
            end

            def query(request)
                query = request[:body][:query]
                docs = []
                opts = {}

                keys, opts[:index] = sort_query_keys(query)
                opts[:loaded] = false

                keys.each do |key|
                    docs = key_search(query, key, docs, opts)
                end

                docs
            end

            def sort_query_keys(query)
                keys = query.keys
                id = !query[:_id].nil?
                index = false

                query.keys.each do |k|
                    if k != :_id && @indexes[k]
                        keys.remove(k)
                        keys.unshift(k)
                        index = true
                    end
                end
                keys.unshift(:_id) if id

                [keys, index || id]
            end

            def key_search(query, key, docs, opts)
                if opts[:loaded]
                    docs = docs.select { |d| d[key] == query[key] }
                else
                    opts[:loaded] = true
                    if opts[:index]
                        docs = index_search(query, key)
                    else
                        docs = file_search(query, key)
                    end
                end
            end

            def index_search(query, key)
                read_documents(@indexes[key].query(query[key]))
            end

            def file_search(query, key)
                docs = []
                @file.rewind
                while !@file.eof?
                    length = @file.read(4).unpack('I')[0]
                    d = BSON.deserialize(@file.read(length))
                    docs << d if d[key.to_s] == query[key]
                end
                docs
            end

            def load_collection
            end

            def read_documents(docs)
                docs.collect do |d|
                    d.read(@file)
                end
            end

            def load_indexes
                @indexes = {
                    _id: Index.new(:_id)
                }
            end

            def to_s
                "<Collection #{@name}>"
            end
        end
    end
end
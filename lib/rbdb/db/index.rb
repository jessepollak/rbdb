module RBDB
    module DB
        class Index
            def initialize(key)
                @key = key
                @store = Hash.new{|hash, key| hash[key] = Array.new}
            end

            def insert(doc)
                @store[doc.send(@key)] << doc
            end

            def query(key)
                @store[key]
            end

            def to_s
                @store.to_s
            end
        end
    end
end
require 'bson'

module RBDB
    module DB
        class Document

            OPTIONS = {
                max_random: 100000000
            }

            def initialize(doc, file)
                unless doc[:_id]
                    @id = Time.now.to_i.to_s(16) + Random.rand(OPTIONS[:max_random]).to_s(16)
                    doc[:_id] = @id
                else
                    @id = doc[:_id]
                end

                bson = BSON.serialize(doc).to_s
                @length = bson.length

                file.seek(0, IO::SEEK_END)

                file.write([@length].pack('I'))
                @start = file.pos
                file.write(bson.to_s)
            end

            def read(file)
                file.seek(@start, IO::SEEK_SET)
                bson = file.read(@length)
                BSON.deserialize(bson)
            end

            def _id
                @id
            end

            def length
                @length
            end

            def start
                @start
            end
        end
    end
end
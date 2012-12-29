$: << File.expand_path(File.dirname(__FILE__) + "/../lib")

require 'json'
require 'rbdb'
require 'fileutils'


db = RBDB::DB::DB.new

insert_request = {
    headers: {
        op_code: 1,
        request_id: 1,
        collection: 'test'
    },
    body: {
        documents: [{
            _id: '2234',
            name: 'Jesse Pollak',
            college: 'Pomona College',
            year: 2015
        },
        {
            _id: '2234',
            name: 'Jesse Pollak',
            college: 'Poop College',
            year: 2015
        },
        {
            _id: '3234',
            name: 'Eli Pollak',
            college: 'Stanford University',
            year: 2012
        }]
    }
}.to_json

query_request = {
    headers: {
        op_code: 3,
        request_id: 2,
        collection: 'test'
    },
    body: {
        query: {
            name: 'Jesse Pollak',
            college: 'Pomona College'
        }
    }
}.to_json


begin
    db.process(insert_request)
    puts db.process(query_request)
ensure
    FileUtils.rm_rf('data')
end
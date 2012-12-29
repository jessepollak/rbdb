RBDB
========

A MongoDB 'clone' (read: 1/10000 of the functionality) written in Ruby to learn more about databases and ruby.

To install the necessary requirements:

    bundle install

To run the database server:

    bin/rbdbd

To run the interactive console that connects to the database:

    bin/rbdb

# How To

Right now, the functionality is pretty limited—you can really only insert and query documents. Furthermore, the indexing is broken (well, not really broken, I just haven't built the persistence functionality), so if you stop your server, you will lose the index on the `_id`, so you won't be able to query it. Let's have some fun!

    db.test.insert({name: 'Jesse Pollak', school: 'Pomona College', year: '2012'})

      => [{"name":"Jesse Pollak","school":"Pomona College","year":"2012","_id":"50df7de82fcbd83"}]

    db.test.query({_id: "50df7de82fcbd83"})

      => [{"name":"Jesse Pollak","school":"Pomona College","year":"2012","_id":"50df7de82fcbd83"}]

    db.test.query({name: "Jesse Pollak"})

      => [{"name":"Jesse Pollak","school":"Pomona College","year":"2012","_id":"50df7de82fcbd83"}]

Hooray!

# TODO

- persist indexes
- add DELETE functionality
- switch to flush writing every 60 seconds






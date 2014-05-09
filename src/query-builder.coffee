_ = require 'lodash'
q = require 'q'
Query = require './query'

class QueryBuilder
    constructor: (db, @transforms = []) ->
        @query = new Query db

    exec = ->
        @query.exec()
        .then (results) =>
            results = results[0] || null if @one # Returns only one object for findOne()
            results

    sort = (sort) ->
        @query.sort = sort
        exec: exec.bind @

    find: (args...) ->
        ### Usage:
            db.find('username', 'fwz')
            db.find('age', [18, 30])
            db.find({ age: [18,20], sort: '+age' })
            db.find({ age: [18,20], sort: { age: 1 }, limit: 3 })
            db.find().where('age', [18, 20])
            db.find().where('age').is().between(18, 20)
            db.find().where('age').is().from(18).to(20)

            Throws an error: db.find({ age: [18,20], sort: [{ age: 1 }, { gender: 1 }] })
        ###
        switch
            # when typeof args[0] is 'undefined'
            #     #
            when typeof args[0] is 'string'
                # db.find('username', 'fwz')
                @query.index = args[0]
                @query.range = args[1]

            when typeof args[0] is 'object'
                object = args[0]
                keys = _.keys object

                if _.include keys, 'limit'
                    @query.limit = object.limit
                    _.pull keys, 'limit'

                if _.include keys, 'sort'
                    @query.sort = object.sort
                    _.pull keys, 'sort'

                if keys.length > 1
                    throw new Error 'QueryBuilder is limited to one key per query'

                @query.index = keys[0] if keys.length
                @query.range = object[@query.index] if keys.length

        exec: exec.bind @
        sort: sort.bind @

    findOne: (args...) ->
        @one = yes
        @query.limit = 1
        @find args...

module.exports = QueryBuilder
_ = require 'lodash'
q = require 'q'
Query = require './query'

class QueryBuilder
    constructor: (@db, @transforms = []) ->
        @query = new Query db

    exec = ->
        @query.exec()
        .then (results) =>
            results = results[0] || null if @one # Returns only one object for findOne()
            results

    sort = (sort) ->
        @query.sort = sort
        exec: exec.bind @

    limit = (limit) ->
        @query.limit = limit
        # { exec }

    _is = () ->
        #
        # { between, sort, limit, skip, exec }

    between = () ->
        #
        # { and, sort, limit, skip, exec }

    from = () ->
        #
        # { to, sort, limit, skip, exec }

    where = (args...) ->
        #
        # ret = { is, between, skip, from, exec }

    find: (args...) ->
        ret =
            exec: exec.bind @
            sort: sort.bind @
            where: where.bind @
            limit: limit.bind @
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
            when _.isString args[0]
                # db.find('username', 'fwz')
                @query.index = args[0]
                @query.range = args[1]

            else
                object = args[0]
                keys = _.keys object

                if _.include keys, 'limit'
                    @query.limit = object.limit
                    _.pull keys, 'limit'
                    delete ret.limit

                if _.include keys, 'sort'
                    @query.sort = object.sort
                    _.pull keys, 'sort'
                    delete ret.sort

                if keys.length > 1
                    throw new Error 'MULTIPLE_INDEXES'

                @query.index = keys[0] if keys.length
                @query.range = object[@query.index] if keys.length

        ret

    findOne: (args...) ->
        @one = yes
        @query.limit = 1
        @find args...

    findById: (args...) ->
        @query.index = @db.keyPath
        query = { }
        switch
            when _.isPlainObject args[0]
                otherIndexes = _.without _.toArray(@db.getIndexList()), @query.index
                if not _.isEmpty _.intersection _.keys(args[0]), otherIndexes
                    throw new Error 'MULTIPLE_INDEXES'
                query = _.omit args[0], otherIndexes
            else
                query[@query.index] = args[0]

        @find query

    findOneById: (args...) ->
        @one = yes
        @query.limit = 1
        @findById args...

module.exports = QueryBuilder
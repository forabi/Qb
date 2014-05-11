q = require 'q'
_ = require 'lodash'

parseSort = (sort) ->
        switch
            when _.isString sort
                m = sort.match /[^\-\+]+/i
                @order = 'DESC' if sort[0] is '-' or sort.match /^des/gi
            when sort is -1
                @order = 'DESC'
            when _.isPlainObject sort
                throw new Error 'INVALID_SORT_KEY' if sort.length > 1
                keys = _.keys sort
                @index = keys[0]
                parseSort.call @, sort[@index]
            else @order = 'ASC'

class Query

    constructor: (@db) ->
    order: 'ASC'
    exclude: [no, no]
    exec: ->
        deferred = q.defer()
        success = deferred.resolve

        # Options for IDBWrapper
        options =
            index: @index || @db.keyPath
            keyRange:
                if !@lower and !@upper then undefined
                else
                    try
                        @db.makeKeyRange({
                            @lower, @upper,
                            excludeLower: @exclude[0],
                            excludeUpper: @exclude[1]
                        })
                    catch err
                        @lower
            order: @order
            onError: deferred.reject

        @db.query success, options
        deferred.promise

# Object.defineProperty Query::, 'index',
#     set: (range) ->
#         # if range instanceof Array
#         #     [@lower, @upper] = range
#         # else @lower = @upper = range

Object.defineProperty Query::, 'range',
    set: (range) ->
        if _.isArray range
            [@lower, @upper] = range
        else @lower = @upper = range
    get: ->
        [@lower, @upper]

Object.defineProperty Query::, 'sort',
    set: (sort) ->
        parseSort.call @, sort

    get: ->
        @order

module.exports = Query
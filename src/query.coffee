q = require 'q'
_ = require 'lodash'

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

# Object.defineProperty Query.prototype, 'index',
#     set: (range) ->
#         # if range instanceof Array
#         #     [@lower, @upper] = range
#         # else @lower = @upper = range

Object.defineProperty Query.prototype, 'range',
    set: (range) ->
        if range instanceof Array
            [@lower, @upper] = range
        else @lower = @upper = range
    get: ->
        [@lower, @upper]

Object.defineProperty Query.prototype, 'sort',
    set: (sort) ->
        parse = (sort) =>
            switch
                when typeof sort is 'string'
                    m = sort.match /[^\-\+]+/i
                    @order = 'DESC' if sort[0] is '-' or sort.match /^des/gi
                when sort is -1
                    @order = 'DESC'
                when typeof sort is 'object'
                    throw new Error 'INVALID_SORT_KEY' if sort.length > 1
                    keys = _.keys sort
                    @index = keys[0]
                    parse sort[@index]
                else @order = 'ASC'
        parse sort

    get: ->
        @order

module.exports = Query
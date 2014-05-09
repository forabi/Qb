people = [
    (_id: 1, username: 'fwz', age: 21)
    (_id: 2, username: 'myd', age: 22)
    (_id: 3, username: 'mnr', age: 23)
]

QueryBuilder = require '../src/query-builder'
IDBStore = require 'idb-wrapper'
_ = require 'lodash'

describe 'QueryBuilder', ->
    store = undefined
    db = undefined

    beforeEach (done) ->
        store = new IDBStore
            storeName: 'people'
            keyPath: '_id'
            autoIncrement: no
            indexes: [
                    (name: '_id', unique: yes)
                    (name: 'username', unique: yes)
                    (name: 'age')
                    ]

        store.onStoreReady = ->
            db =
                find: (args...) -> (new QueryBuilder(store)).find args...
                findOne: (args...) -> (new QueryBuilder(store)).findOne args...
                # findById: (args...) -> (new QueryBuilder(store)).findById args...
                # findOneById: (args...) -> (new QueryBuilder(store)).findOneById args...
                # where: (args...) -> (new QueryBuilder(store)).where args...

            store.putBatch people, done

    beforeEach ->
        jasmine.DEFAULT_TIMEOUT_INTERVAL = 5000

    it 'should have a find method', ->
        expect(db.find).toBeDefined()

    describe 'find()', ->
        describe 'find()', ->
            it 'should get an array of all people', (done) ->
                transaction = db.find('_id')
                transaction.exec()
                .then (result) ->
                    expect result
                    .toEqual people

                    done()
                .catch (err) -> throw err

        describe 'find({ sort: -1 })', ->
            it 'should get an array of all people in reverse order', (done) ->
                transaction = db.find({ sort: -1 })
                transaction.exec()
                .then (result) ->
                    expect result[0]._id
                    .toEqual _.last(people)._id

                    done()
                .catch (err) -> throw err

        describe 'find({ _id: [1, 2], sort: -1 })', ->
            it 'should get an array of first 2 people in reverse order', (done) ->
                transaction = db.find({ _id: [1, 2], sort: -1 })
                transaction.exec()
                .then (result) ->
                    expect result.length
                    .toEqual 2

                    expect result[0]._id
                    .toEqual 2

                    done()
                .catch (err) -> throw err

        describe 'Non-primary index: find("age", 22)', ->
            it 'should get an array with 1 person whose age is 22', (done) ->
                transaction = db.find('age', 22)
                transaction.exec()
                .then (result) ->
                    expect result[0].age
                    .toEqual 22
                    done()
                .catch (err) -> throw err

    describe 'findOne()', ->
        describe 'findOne()', ->
            it 'should return the first person as object (not array)', (done) ->
                transaction = db.findOne()
                transaction.exec()
                .then (result) ->
                    expect result
                    .toEqual people[0]
                    done()
                .catch (err) -> throw err

        describe 'findOne({age: 22})', ->
            it 'should return the first person whose age is 22', (done) ->
                transaction = db.findOne({age: 22})
                transaction.exec()
                .then (result) ->
                    expect result.age
                    .toEqual 22
                    done()
                .catch (err) -> throw err

        describe 'findOne({sort: -1})', ->
            it 'should return the last person as object (not array)', (done) ->
                transaction = db.findOne({sort: -1})
                transaction.exec()
                .then (result) ->
                    expect result
                    .toEqual _.last people
                    done()
                .catch (err) -> throw err

        describe 'findOne({sort: "-age"})', ->
            it 'should return the oldest person', (done) ->
                transaction = db.findOne({sort: "-age"})
                transaction.exec()
                .then (result) ->
                    expect result.age
                    .toEqual _.chain(people).sortBy('age').last().value().age
                    done()
                .catch (err) -> throw err

    describe 'sort()', ->
        describe 'find().sort("-age")', ->
            it 'should return an array of people sorted by age descending', (done) ->
                transaction = db.find().sort('-age')
                transaction.exec()
                .then (result) ->
                    expect result.length
                    .toEqual people.length

                    expect result[0].age
                    .toEqual _.chain(people).sortBy('age').last().value().age
                    done()
                .catch (err) -> throw err

        describe 'find().sort({ age: -1 })', ->
            it 'should return an array of people sorted by age descending', (done) ->
                transaction = db.find().sort({ age: -1 })
                transaction.exec()
                .then (result) ->
                    expect result.length
                    .toEqual people.length

                    expect result[0].age
                    .toEqual _.chain(people).sortBy('age').last().value().age
                    done()
                .catch (err) -> throw err

        describe 'find().sort({ age: "DESC" })', ->
            it 'should return an array of people sorted by age descending', (done) ->
                transaction = db.find().sort({ age: "DESC" })
                transaction.exec()
                .then (result) ->
                    expect result[0].age
                    .toEqual _.chain(people).sortBy('age').last().value().age

                    done()
                .catch (err) -> throw err

        describe 'find("age").sort("DESC")', ->
            it 'should return an array of people sorted by age descending', (done) ->
                transaction = db.find("age").sort("DESC")
                transaction.exec()
                .then (result) ->
                    expect result[0].age
                    .toEqual _.chain(people).sortBy('age').last().value().age

                    done()
                .catch (err) -> throw err

        describe 'find().sort("DESC")', ->
            it 'should return an array of people in reverse order', (done) ->
                transaction = db.find().sort("DESC")
                transaction.exec()
                .then (result) ->
                    expect result[0]
                    .toEqual _.last people

                    done()
                .catch (err) -> throw err
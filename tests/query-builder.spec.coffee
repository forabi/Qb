people = [
    (_id: 1, username: 'fwz', age: 21)
    (_id: 2, username: 'myd', age: 22)
    (_id: 3, username: 'mnr', age: 23)
]

QueryBuilder = require '../src/query-builder'
IDBStore = require 'idb-wrapper'
_ = require 'lodash'

describe 'QueryBuilder', ->

    beforeEach (done) ->
        @store = new IDBStore
            storeName: 'people'
            keyPath: '_id'
            autoIncrement: no
            indexes: [
                    (name: '_id', unique: yes)
                    (name: 'username', unique: yes)
                    (name: 'age')
                    ]

        @store.onStoreReady = =>
            @db =
                find: (args...) => (new QueryBuilder(@store)).find args...
                findOne: (args...) => (new QueryBuilder(@store)).findOne args...
                # findById: (args...) -> (new QueryBuilder(@store)).findById args...
                # findOneById: (args...) -> (new QueryBuilder(@store)).findOneById args...
                # where: (args...) -> (new QueryBuilder(@store)).where args...

            @store.putBatch people, done

    beforeEach ->
        jasmine.DEFAULT_TIMEOUT_INTERVAL = 5000

    it 'should have a find method', ->
        expect(@db.find).toBeDefined()

    describe 'find()', ->
        describe 'find()', ->
            beforeEach (done) ->
                @db.find('_id').exec()
                .then (result) =>
                    @result = result
                    done()

                .catch (err) -> throw err

            it 'should get an array of all people', ->
                expect(@result.length).toEqual people.length
                expect(@result).toEqual people


        describe 'find({ sort: -1 })', ->
            beforeEach (done) ->
                @db.find(sort: -1).exec()
                .then (result) =>
                    @result = result
                    done()

                .catch (err) -> throw err

            it 'should get an array of all people in reverse order', ->
                expect(@result[0]._id).toEqual _.last(people)._id
                expect(@result.length).toEqual people.length


        describe 'find({ _id: [1, 2], sort: -1 })', ->
            beforeEach (done) ->
                @db.find(_id: [1, 2], sort: -1).exec()
                .then (result) =>
                    @result = result
                    done()

                .catch (err) -> throw err

            it 'should get an array of first 2 people in reverse order', ->
                expect(@result.length).toEqual 2
                expect(@result[0]._id).toEqual 2


        describe 'Non-primary index: find("age", 22)', ->
            beforeEach (done) ->
                @db.find('age', 22).exec()
                .then (result) =>
                    @result = result
                    done()

                .catch (err) -> throw err

            it 'should get an array with 1 person whose age is 22', ->
                expect(@result[0].age).toEqual 22
                expect(@result.length).toEqual 1


    describe 'findOne()', ->
        describe 'findOne()', ->
            beforeEach (done) ->
                @db.findOne().exec()
                .then (result) =>
                    @result = result
                    done()

                .catch (err) -> throw err

            it 'should return the first person as object (not array)', ->
                expect(@result).toEqual people[0]


        describe 'findOne({age: 22})', ->
            beforeEach (done) ->
                @db.findOne(age: 22).exec()
                .then (result) =>
                    @result = result
                    done()

                .catch (err) -> throw err

            it 'should return the first person whose age is 22', ->
                expect(@result.age).toEqual 22


        describe 'findOne({sort: -1})', ->
            beforeEach (done) ->
                @db.findOne(sort: -1).exec()
                .then (result) =>
                    @result = result
                    done()

                .catch (err) -> throw err

            it 'should return the last person as object (not array)', ->
                expect(@result).toEqual _.last(people)


        describe 'findOne({sort: "-age"})', ->
            beforeEach (done) ->
                @db.findOne(sort: '-age').exec()
                .then (result) =>
                    @result = result
                    done()

                .catch (err) -> throw err

            it 'should return the oldest person', ->
                expect(@result.age)
                    .toEqual _.chain(people).sortBy('age').last().value().age


    describe 'sort()', ->
        describe 'find().sort("-age")', ->
            beforeEach (done) ->
                @db.find().sort('-age').exec()
                .then (result) =>
                    @result = result
                    done()

                .catch (err) -> throw err

            it 'should return an array of people sorted by age descending', ->
                expect(@result.length).toEqual people.length
                expect(@result[0].age)
                    .toEqual _.chain(people).sortBy('age').last().value().age


        describe 'find().sort({ age: -1 })', ->
            beforeEach (done) ->
                @db.find().sort(age: -1).exec()
                .then (result) =>
                    @result = result
                    done()

                .catch (err) -> throw err

            it 'should return an array of people sorted by age descending', ->
                expect(@result.length).toEqual people.length
                expect(@result[0].age)
                    .toEqual _.chain(people).sortBy('age').last().value().age


        describe 'find().sort({ age: "DESC" })', ->
            beforeEach (done) ->
                @db.find().sort(age: 'DESC').exec()
                .then (result) =>
                    @result = result
                    done()

                .catch (err) -> throw err

            it 'should return an array of people sorted by age descending', ->
                expect(@result.length).toEqual people.length
                expect(@result[0].age)
                    .toEqual _.chain(people).sortBy('age').last().value().age


        describe 'find("age").sort("DESC")', ->
            beforeEach (done) ->
                @db.find('age').sort('DESC').exec()
                .then (result) =>
                    @result = result
                    done()

                .catch (err) -> throw err

            it 'should return an array of people sorted by age descending', ->
                expect(@result.length).toEqual people.length
                expect(@result[0].age)
                    .toEqual _.chain(people).sortBy('age').last().value().age


        describe 'find().sort("DESC")', ->
            beforeEach (done) ->
                @db.find().sort('desc').exec()
                .then (result) =>
                    @result = result
                    done()

                .catch (err) -> throw err

            it 'should return an array of people in reverse order', ->
                expect(@result.length).toEqual people.length
                expect(@result[0]).toEqual _.last people

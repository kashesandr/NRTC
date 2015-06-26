require 'coffee-script'
chai = require 'chai'
should = require "should"
sinon = require 'sinon'
Q = require 'q'
Parse = require('parse').Parse
DataStorage = require './controller'

expect = chai.expect

testConfigs =
  "applicationId": "hZ9REGxSlyuHw8FQrhWuDtNndHJYYN3ZtncLEpup",
  "javascriptKey": "9pnVzHopo1SC3sWAfG4Ajk4sdtZeBzQVNjM6CEsf"
  "masterKey": "uwVtuFqpSnLxwus1Aa8TDBlZtMV6rgiy7gvYpvMy"

Parse.initialize(
  testConfigs.applicationId
  testConfigs.javascriptKey
)

controller = new DataStorage testConfigs

deleteAllEntries = (className) ->
  deferred = Q.defer()
  controller.deleteAll className, (error, result) ->
    deferred.resolve()
  deferred.promise

describe 'dataStorage instance', ->

  it 'should exist', ->
    controller.should.exists

  describe 'has a working method', ->

    #beforeEach (done) ->
      #Q.all(
        #deleteAllEntries('Test')
        #deleteAllEntries('User')
      #).then done()

    it 'insert', (done) ->

      controller.insert.should.exists

      controller.insert('Test', {action: 'insert'})
      .then (id) ->
        Inserted = Parse.Object.extend 'Test'
        query = new Parse.Query Inserted
        query.get id,
          success: (result) ->
            expect(result.attributes).to.deep.equal {action: 'insert'}
            setTimeout done(), 4000

    describe 'find', ->

      it 'exists', ->
        controller.find.should.exists

      it 'if an entry exists', (done) ->

        controller.insert('Test', {action: 'find'})
        .then (id) ->
          controller.find 'Test', [ {key:'action',value:'find'} ]
        .then (results) ->
          expect(results[0].attributes).to.deep.equal {action: 'find'}
          setTimeout done(), 4000

      it 'if no entries', (done) ->
        controller.find('Test', [ {key:'action',value:'not-existing'} ])
        .then (results) ->
          results.should.have.length 0
          setTimeout done(), 4000

    describe 'findById', ->

      it 'exists', ->
        controller.findById.should.exists

      it 'if an entry exists', (done) ->
        controller.insert 'Test', {action:'findById'}
        .then (id) ->
          controller.findById 'Test', id
        .then (result) ->
          expect(result.attributes).to.deep.equal {action:'findById'}
          setTimeout done(), 4000

      it 'if no entries', (done) ->
        controller.findById 'Test', 'not-existing'
        .catch (error) ->
          error.code.should.equal 101
          setTimeout done(), 4000


    describe 'delete', ->

      it 'exists', ->
        controller.delete.should.exists

      it 'if an entry exists', (done) ->

        _id = null

        controller.insert('Test', {action: 'delete'})
        .then (id) ->
          _id = id
          controller.delete 'Test', id
        .then (id) ->
          expect(id).to.equal _id
          setTimeout done(), 4000

      it 'if nothing to delete', (done) ->
        controller.delete('Test', 'not-existing')
        .catch (error) ->
          error.code.should.equal 101
          setTimeout done(), 4000

    describe 'update', ->

      it 'exists', ->
        controller.update.should.exists

      it 'if an entry exists', (done) ->

        controller.insert('Test', {action: 'pre-update'})
        .then (id) ->
          controller.update 'Test', id, {action: 'update'}
        .then (id) ->
          controller.findById 'Test', id
        .then (result) ->
          expect(result.attributes).to.deep.equal {action: 'update'}
          setTimeout done(), 4000

      it 'if no entries', (done) ->
        controller.update('Test', 'not-existing', {action: 'update'})
        .catch (error) ->
          error.code.should.equal 101
          setTimeout done(), 4000


    ###
      save logs when user enters/exits
      Input: <String> code
      Output: <String> action # enter / exit
    ###
    describe.only 'log', ->

      sandbox = null

      beforeEach ->
        sandbox = sinon.sandbox.create()
      afterEach ->
        sandbox.restore()

      it 'exists', ->
        controller.log.should.exists

      it 'when a user enters for the first time', (done) ->

        controller.createUser = sandbox.stub().returns({})

        controller.log('code')
        .then (user) ->
          #expect(controller.createUser.called).to.equal true
          setTimeout done(), 4000

      xit 'when a user enters', (done) ->
        controller.log('code')
        .then (action) ->
          action.should.equal 'enter'
          setTimeout done(), 4000

      xit 'when a user exits', (done) ->
        # dataStorage logs should already have
        # the entry with action=`enter`

        controller.log('code')
        .then (action) ->
          action.should.equal 'exit'
          setTimeout done(), 4000

    # input data: <String> code
    # output:
    # 1) returns a created user
    # 2) returns an already existing user with the provided code
    describe 'createUser', ->

      it 'should exist', ->
        controller.createUser.should.exists

      it 'when a user does not exists', (done) ->
        code = 'a-new-code'
        controller.createUser(code)
        .then (user) ->
          user.get('code').should.equal code
          expect(user.get 'logs').to.deep.equal []
          setTimeout done(), 4000

      it 'when a user exists already', (done) ->

        code = 'an-existing-code'
        _user = null

        controller.createUser(code)
        .then (user) ->
          _user = user
          controller.createUser(code)
        .then (user) ->
          expect(user.attributes).to.deep.equal _user.attributes
          expect(user.id).to.equal _user.id
          setTimeout done(), 4000
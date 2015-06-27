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

describe 'dataStorage instance', ->

  it 'should exist', ->
    controller.should.exists

  describe 'has a working method', ->

    afterEach (done) ->
      Q.all(
        controller.deleteAll('Test')
        controller.deleteAll('Users')
        controller.deleteAll('Logs')
      ).then done()

    it 'insert', (done) ->

      controller.insert.should.exists

      controller.insert('Test', {action: 'insert'})
      .then (id) ->
        Inserted = Parse.Object.extend 'Test'
        query = new Parse.Query Inserted
        query.get id,
          success: (result) ->
            expect(result.attributes).to.deep.equal {action: 'insert'}
            setTimeout done(), 5000

    describe 'find', ->

      it 'exists', ->
        controller.find.should.exists

      it 'if an entry exists', (done) ->

        controller.insert('Test', {action: 'find'})
        .then (id) ->
          controller.find 'Test', [ {key:'action',value:'find'} ]
        .then (results) ->
          expect(results[0].attributes).to.deep.equal {action: 'find'}
          setTimeout done(), 5000

      it 'if no entries', (done) ->
        controller.find('Test', [ {key:'action',value:'not-existing'} ])
        .catch (result) ->
          expect(result).to.equal null
          setTimeout done(), 5000

    describe 'findById', ->

      it 'exists', ->
        controller.findById.should.exists

      it 'if an entry exists', (done) ->
        controller.insert 'Test', {action:'findById'}
        .then (id) ->
          controller.findById 'Test', id
        .then (result) ->
          expect(result.attributes).to.deep.equal {action:'findById'}
          setTimeout done(), 5000

      it 'if no entries', (done) ->
        controller.findById 'Test', 'not-existing'
        .catch (result) ->
          expect(result).to.equal null
          setTimeout done(), 5000

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
          setTimeout done(), 5000

      it 'if nothing to delete', (done) ->
        controller.delete('Test', 'not-existing')
        .catch (result) ->
          expect(result).to.equal null
          setTimeout done(), 5000

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
          result.get('action').should.equal 'update'
          setTimeout done(), 5000

      it 'if no entries', (done) ->
        controller.update('Test', 'not-existing', {action: 'update'})
        .catch (result) ->
          expect(result).to.equal null
          setTimeout done(), 5000


    ###
      save logs when user enters/exits
      Input: <String> code
      Output: <String> action # enter / exit
    ###
    describe.only 'log', ->

      it 'exists', ->
        controller.log.should.exists

      it 'when a user enters for the first time', (done) ->

        controller.log('Logs', 'code')
        .then (log) ->
          controller.findById "Users", log.get('parent').id
        .then (user) ->
          expect(user.get('code')).to.equal 'code'
          setTimeout done(), 5000

      xit 'when a user enters', (done) ->
        controller.log('Logs', 'code')
        .then (action) ->
          action.should.equal 'enter'
          setTimeout done(), 5000

      xit 'when a user exits', (done) ->
        # dataStorage logs should already have
        # the entry with action=`enter`

        controller.log('Logs', 'code')
        .then (action) ->
          action.should.equal 'exit'
          setTimeout done(), 5000

    # input data: <String> code
    # output:
    # 1) returns a created user
    # 2) returns an already existing user with the provided code
    describe 'createUser', ->

      it 'should exist', ->
        controller.createUser.should.exists

      it 'when a user does not exists', (done) ->
        code = 'a-new-code'
        controller.createUser('Users', code)
        .then (user) ->
          user.get('code').should.equal code
          expect(user.get 'logs').to.deep.equal []
          setTimeout done(), 5000

      it 'when a user exists already', (done) ->

        code = 'an-existing-code'
        _user = null

        controller.createUser('Users', code)
        .then (user) ->
          _user = user
          controller.createUser('Users', code)
        .then (user) ->
          expect(user.attributes).to.deep.equal _user.attributes
          expect(user.id).to.equal _user.id
          setTimeout done(), 5000
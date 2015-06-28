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
      @timeout 8000
      Q.all(
        controller.deleteAll('Test')
        controller.deleteAll('Users')
        controller.deleteAll('Logs')
      ).then done()

    it 'insert', (done) ->
      @timeout 8000

      controller.insert.should.exists

      controller.insert('Test', {action: 'insert'})
      .then (result) ->
        Inserted = Parse.Object.extend 'Test'
        query = new Parse.Query Inserted
        query.get result.id,
          success: (result) ->
            result.get('action').should.equal 'insert'
            done()

    describe 'find', ->

      it 'exists', ->
        controller.find.should.exists

      it 'if an entry exists', (done) ->
        @timeout 8000

        controller.insert('Test', {action: 'find'})
        .then (result) ->
          controller.find 'Test', [ {key:'action',value:'find'} ]
        .then (results) ->
          results[0].get('action').should.equal 'find'
          done()

      it 'if no entries', (done) ->
        @timeout 8000
        controller.find('Test', [ {key:'action',value:'not-existing'} ])
        .then (results) ->
          expect(results).to.deep.equal []
          done()

    describe 'findById', ->

      it 'exists', ->
        controller.findById.should.exists

      it 'if an entry exists', (done) ->
        @timeout 8000
        controller.insert 'Test', {action:'findById'}
        .then (result) ->
          controller.findById 'Test', result.id
        .then (result) ->
          result.get('action').should.equal 'findById'
          done()

      it 'if no entries', (done) ->
        @timeout 8000
        controller.findById 'Test', 'not-existing'
        .then (result) ->
          expect(result).to.equal null
          done()

    describe 'findLatest', ->

      it 'exists', ->
        controller.findLatest.should.exists

      it 'if entries', (done) ->
        @timeout 10000

        controller.insert('Test', action:'findLatest-2')
        .then (result) ->
          controller.insert('Test', action:'findLatest-2')
        .then (result) ->
          controller.insert('Test', action:'findLatest-3')
        .then (result) ->
          controller.findLatest('Test')
        .then (latest) ->
          latest[0].get('action').should.equal 'findLatest-3'
          controller.findLatest('Test', [{key:'action',value:'findLatest-2'}], 1)
        .then (latest) ->
          latest[0].get('action').should.equal 'findLatest-2'
          controller.findLatest('Test', [], 2)
        .then (latest) ->
          latest.should.have.length 2
          latest[0].get('action').should.equal 'findLatest-3'
          latest[1].get('action').should.equal 'findLatest-2'
          done()

      it 'if no entries', (done) ->
        @timeout 8000
        controller.findLatest('Test3')
        .then (results) ->
          results.should.have.length 0
          done()

    describe 'delete', ->

      it 'exists', ->
        controller.delete.should.exists

      it 'if an entry exists', (done) ->
        @timeout 8000

        _id = null

        controller.insert('Test', {action: 'delete'})
        .then (result) ->
          _id = result.id
          controller.delete 'Test', _id
        .then (result) ->
          expect(result.id).to.equal _id
          done()

      it 'if nothing to delete', (done) ->
        @timeout 8000
        controller.delete('Test', 'not-existing')
        .then (result) ->
          expect(result).to.equal null
          done()

    describe 'update', ->

      it 'exists', ->
        controller.update.should.exists

      it 'if an entry exists', (done) ->
        @timeout 8000

        controller.insert('Test', {action: 'pre-update'})
        .then (result) ->
          controller.update 'Test', result.id, {action: 'update'}
        .then (result) ->
          controller.findById 'Test', result.id
        .then (result) ->
          result.get('action').should.equal 'update'
          done()

      it 'if no entries', (done) ->
        @timeout 8000
        controller.update('Test', 'not-existing', {action: 'update'})
        .catch (result) ->
          expect(result).to.equal null
          done()

    # input data: <String> code
    # output:
    # 1) returns a created user
    # 2) returns an already existing user with the provided code
    describe 'getUser', ->

      it 'should exist', ->
        controller.getUser.should.exists

      it 'when a user does not exists', (done) ->
        @timeout 8000
        code = 'a-new-code'
        controller.getUser('Users', code)
        .then (user) ->
          user.get('code').should.equal code
          expect(user.get 'logs').to.deep.equal []
          done()

      it 'when a user exists already', (done) ->
        @timeout 8000

        code = 'an-existing-code'
        _user = null

        controller.getUser('Users', code)
        .then (user) ->
          _user = user
          controller.getUser('Users', code)
        .then (user) ->
          expect(user.attributes).to.deep.equal _user.attributes
          expect(user.id).to.equal _user.id
          done()

    ###
      save logs when user enters/exits
      Input: <String> code
      Output: <String> action # enter / exit
    ###
    describe 'log', ->

      it 'exists', ->
        controller.log.should.exists

      it 'when a user enters for the first time', (done) ->
        @timeout 10000

        controller.log('Logs', 'not-existing-code')
        .then (log) ->
          log.get('action').should.equal 'enter'
          controller.findById "Users", log.get('parentId')
        .then (user) ->
          expect(user.get('code')).to.equal 'not-existing-code'
          done()

      it 'when a user exits', (done) ->
        @timeout 8000

        _log = null

        # when a user enters
        controller.log('Logs', 'existing-code')
        .then (log) ->
          # and then the user exits
          controller.log 'Logs', 'existing-code'
        .then (log) ->
          # the action should be 'exit'
          log.get('action').should.equal 'exit'
          controller.find('Logs', [{key:'parentId',value:log.get('parentId')}])
        .then (results) ->
          # and there should be 2 log entries in Logs
          results.should.have.length 2
          done()
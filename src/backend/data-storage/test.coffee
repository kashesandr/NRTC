require 'coffee-script'
chai = require 'chai'
should = require "should"
Q = require 'q'
Parse = require('parse').Parse
DataStorage = require './controller'
expect = chai.expect

testConfigs =
  parse:
    "applicationId": "hZ9REGxSlyuHw8FQrhWuDtNndHJYYN3ZtncLEpup",
    "javascriptKey": "9pnVzHopo1SC3sWAfG4Ajk4sdtZeBzQVNjM6CEsf"
    "masterKey": "uwVtuFqpSnLxwus1Aa8TDBlZtMV6rgiy7gvYpvMy"
  className:
    logs: 'Logs'
    users: 'Users'

Parse.initialize(
  testConfigs.parse.applicationId
  testConfigs.parse.javascriptKey
)

controller = null

describe 'DataStorage', ->

  it 'should have a error when not correctly initialized', ->
    controller = new DataStorage {}
    controller.error.should.equal true

    controller = new DataStorage {parse:{}}
    controller.error.should.equal true

    controller = new DataStorage {parse:applicationId:'foo'}
    controller.error.should.equal true

    controller = new DataStorage {parse:javascriptKey:'foo'}
    controller.error.should.equal true

    controller = new DataStorage
      parse:
        applicationId:'foo'
        javascriptKey:'bar'
    controller.error.should.equal true

    controller = new DataStorage
      className:
        logs: 'Logs'
    controller.error.should.equal true

    controller = new DataStorage
      className:
        users: 'Users'
    controller.error.should.equal true

    controller = new DataStorage
      className:
        logs: 'Logs'
        users: 'Users'
    controller.error.should.equal true

  describe 'should', ->

    beforeEach (done) ->
      @timeout 10000
      controller = new DataStorage testConfigs
      setTimeout done, 500

    it 'exist', ->
      controller.should.exists

    it 'be initialized correctly', ->
      controller.error.should.equal false
      controller.className.logs.should.equal 'Logs'
      controller.className.users.should.equal 'Users'

    describe 'have', ->

      afterEach (done) ->
        @timeout 10000
        Q.all(
          controller.deleteAll('Test')
          controller.deleteAll('Logs')
          controller.deleteAll('Users')
        ).then(setTimeout done, 1000)

      describe 'a generic method', ->

        describe '`insert` which', ->

          it 'exists', ->
            controller.insert.should.exists

          it 'works correctly', (done) ->
            @timeout 10000
            controller.insert('Test', {action: 'insert'})
            .then (result) ->
              Inserted = Parse.Object.extend 'Test'
              query = new Parse.Query Inserted
              query.get result.id,
                success: (result) ->
                  result.get('action').should.equal 'insert'
                  done()

        describe '`find` which', ->

          it 'exists', ->
            controller.find.should.exists

          it 'works fine', (done) ->
            @timeout 10000

            controller.insert('Test', {action:'find'})
            .then (result) ->
              controller.find 'Test', [ {key:'action',value:'find'} ]
            .then (results) ->
              results[0].get('action').should.equal 'find'
              done()

          it 'works fine when no search results', (done) ->
            @timeout 10000

            controller.find('Test', [ {key:'action',value:'not-existing'} ])
            .then (results) ->
              expect(results).to.deep.equal []
              done()

        describe '`findById` which', ->

          it 'exists', ->
            controller.findById.should.exists

          it 'works fine', (done) ->
            @timeout 10000

            controller.insert 'Test', {action:'findById'}
            .then (result) ->
              controller.findById 'Test', result.id
            .then (result) ->
              result.get('action').should.equal 'findById'
              done()

          it 'works fine when no search results', (done) ->
            @timeout 10000

            controller.findById 'Test', 'not-existing'
            .then (result) ->
              expect(result).to.equal null
              done()

        describe '`findLatest` which', ->

          it 'exists', ->
            controller.findLatest.should.exists

          it 'works fine', (done) ->
            @timeout 10000

            Q.all(
              controller.insert('Test', action:'findLatest-2'),
              controller.insert('Test', action:'findLatest-2'),
              controller.insert('Test', action:'findLatest-3')
            ).then (result) ->
              controller.findLatest('Test') # the latest
            .then (latest) ->
              latest.should.have.length 3
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

          it 'works fine when no search results', (done) ->
            @timeout 10000

            controller.findLatest('Test3')
            .then (results) ->
              results.should.have.length 0
              done()

        describe '`delete` which', ->

          it 'exists', ->
            controller.delete.should.exists

          it 'works fine', (done) ->
            @timeout 10000

            expectId = null

            controller.insert('Test', {action: 'delete'})
            .then (result) ->
              expectId = result.id
              controller.delete 'Test', expectId
            .then (result) ->
              expect(result.id).to.equal expectId
              done()

          it 'works fine when nothing to delete', (done) ->
            @timeout 10000

            controller.delete('Test', 'not-existing')
            .then (result) ->
              expect(result).to.equal null
              done()

        describe '`update` which', ->

          it 'exists', ->
            controller.update.should.exists

          it 'works fine', (done) ->
            @timeout 10000

            controller.insert('Test', {action: 'pre-update'})
            .then (result) ->
              controller.update 'Test', result.id, {action: 'update'}
            .then (result) ->
              controller.findById 'Test', result.id
            .then (result) ->
              result.get('action').should.equal 'update'
              done()

          it 'works fine when nothing to update', (done) ->
            @timeout 10000

            controller.update('Test', 'not-existing', {action: 'update'})
            .catch (result) ->
              expect(result).to.equal null
              done()

      describe 'a method', ->

        describe '`getUser` which', ->

          it 'exist', ->
            controller.getUser.should.exists

          it 'works fine', (done) ->
            @timeout 10000

            code = 'a-new-code'
            controller.getUser(code)
            .then (user) ->
              user.get('code').should.equal code
              done()

          it 'works fine when a user with such code exists already', (done) ->
            @timeout 10000

            existingCode = 'an-existing-code'
            expectedUser = null

            controller.getUser(existingCode)
            .then (user) ->
              expectedUser = user
              controller.getUser(existingCode)
            .then (user) ->
              expect(user.attributes).to.deep.equal(
                expectedUser.attributes
              )
              expect(user.id).to.equal expectedUser.id
              done()

        describe '`log` which', ->

          it 'exists', ->
            controller.log.should.exists

          it 'works fine when a user enters', (done) ->
            @timeout 10000

            controller.log('not-existing-code')
            .then (log) ->
              log.get('action').should.equal 'enter'
              controller.findById "Users", log.get('parentId')
            .then (user) ->
              user.get('code').should.equal 'not-existing-code'
              user.get('isOnline').should.equal true
              done()

          it 'works fine when a user exits', (done) ->
            @timeout 10000

            _parentId = null

            # when a user enters
            controller.log('existing-code')
            .then (log) ->
              # and then the user exits
              controller.log 'existing-code'
            .then (log) ->
              # the last action should be 'exit'
              _parentId = log.get('parentId')
              log.get('action').should.equal 'exit'
              controller.find('Logs', [{key:'parentId',value:_parentId}])
            .then (results) ->
              # and there should be 2 log entries in Logs for the user
              results.should.have.length 2
              controller.findById('Users', _parentId)
            .then (user) ->
              user.get('isOnline').should.equal false
              done()
require 'coffee-script'
chai = require 'chai'
should = require "should"
sinon = require 'sinon'
Q = require 'q'

expect = chai.expect

DataStorage = require './controller'
controller = new DataStorage
  parse:
    "applicationId": "hZ9REGxSlyuHw8FQrhWuDtNndHJYYN3ZtncLEpup"
    "javascriptKey": "9pnVzHopo1SC3sWAfG4Ajk4sdtZeBzQVNjM6CEsf"
    "masterKey": "uwVtuFqpSnLxwus1Aa8TDBlZtMV6rgiy7gvYpvMy"
  table: 'test'

describe 'dataStorage instance', ->

  parseInstance = controller.parseInstance

  deleteAllEntries = (className) ->
    deferred = Q.defer()
    parseInstance.deleteAll className, (error, result) ->
      deferred.resolve()
    deferred.promise

  it 'should exist', ->
    controller.should.exists

  describe 'has a working method', ->

    beforeEach (done) ->
      Q.all(
        deleteAllEntries('Test')
        #deleteAllEntries('User')
      ).then done()

    it 'insert', (done) ->

      controller.insert.should.exists

      controller.insert('Test', {action: 'insert'})
      .then (objectId) ->
        parseInstance.find 'Test', {objectId: objectId}, (error, response) ->
          result = response.results[0]
          result.action.should.equal 'insert'
          setTimeout done(), 1000

    it 'find', (done) ->

      controller.find.should.exists

      controller.insert('Test', {action: 'find'})
      .then (objectId) ->
        controller.find 'Test', {objectId: objectId}
      .then (results) ->
        results[0].action.should.equal 'find'
        setTimeout done(), 1000

    it 'delete', (done) ->

      controller.delete.should.exists

      controller.insert('Test', {action: 'delete'})
      .then (objectId) ->
        controller.delete 'Test', objectId
      .then (response) ->
        controller.find 'Test', {objectId: response}
      .then (results) ->
        results.should.have.length 0
        setTimeout done(), 1000

    it 'update', (done) ->

      controller.update.should.exists

      controller.insert('Test', {action: 'bar'})
      .then (objectId) ->
        controller.update 'Test', objectId, {action: 'update'}
      .then (data) ->
        data.action.should.equal 'update'
        setTimeout done(), 1000


    ###
      save logs when user enters/exits
      Input: <String> code
      Output: <String> action # enter / exit
    ###
    describe 'log', ->

      it 'exists', ->
        controller.log.should.exists

      it.only 'when a user enters for the first time', (done) ->

        #spy = sinon.spy controller, 'createUser'

        controller.log('code')
        .then (user) ->
          #expect(user).to.equal null
          #expect(controller.createUser).to.equal true
          setTimeout done(), 2000

      xit 'when a user enters', (done) ->
        controller.log('code')
        .then (action) ->
          action.should.equal 'enter'
          done()

      xit 'when a user exits', (done) ->
        # dataStorage logs should already have
        # the entry with action=`enter`

        controller.log('code')
        .then (action) ->
          action.should.equal 'exit'
          done()

    # input data: <String> code
    # output:
    # 1) returns a created user with empty name/surname
    # 2) returns an already existing user with the provided code
    describe 'createUser', ->

      it 'should exist', ->
        controller.createUser.should.exists

      xit 'when a user does not exists', (done) ->
        code = 'a-new-code'
        controller.createUser(code)
        .then (user) ->
          user.code.should.equal code
          user.name.should.equal ''
          user.surname.should.equal ''
          user.log.should.deep.equal []
          done()

      xit 'when a user exists already', (done) ->

        timestampEnter = (new Date()).getTime()
        code = 'existing-user'

        # mock an existing user
        existingUser =
          code: code
          name: 'name'
          surname: 'surname'
          log: [
            {
              action: 'enter'
              timestamp: timestampEnter
            }
          ]
        # insert existing user into the storage

        controller.createUser(code)
        .then (user) ->
          user.code.should.equal existingUser.code
          user.name.should.equal existingUser.name
          user.surname.should.equal existingUser.surname
          user.log.should.have.length existingUser.log.length
          done()
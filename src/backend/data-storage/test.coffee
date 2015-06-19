require 'coffee-script'
should = require "should"
chai = require 'chai'
expect = chai.expect
async = require 'async'
moment = require 'moment'

DataStorage = require './controller'

describe 'DataStorage', ->

  it 'should exist', ->
    DataStorage.should.exists

  describe 'has a working method', ->

    it 'insert', ->
      DataStorage.insert.should.exists

    it 'update', ->
      DataStorage.update.should.exists

    ###
      save logs when user enters/exits
      Input: <String> code
      Output: <String> action # enter / exit
    ###
    describe 'log', ->

      it 'exists', ->
        DataStorage.log.should.exists

      xit 'checks if user already exists', ->


      xit 'when a user enters', (done) ->
        DataStorage.log('code')
        .then (action) ->
          action.should.equal 'enter'
          done()

      xit 'when a user exits', (done) ->
        # DataStorage logs should already have
        # the entry with action=`enter`

        DataStorage.log('code')
        .then (action) ->
          action.should.equal 'exit'
          done()

    # input data: <String> code
    # output:
    # 1) returns a created user with empty name/surname
    # 2) returns an already existing user with the provided code
    describe 'createUser', ->

      it 'should exist', ->
        DataStorage.createUser.should.exists

      xit 'when a user does not exists', (done) ->
        code = 'a-new-code'
        DataStorage.createUser(code)
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

        DataStorage.createUser(code)
        .then (user) ->
          user.code.should.equal existingUser.code
          user.name.should.equal existingUser.name
          user.surname.should.equal existingUser.surname
          user.log.should.have.length existingUser.log.length
          done()
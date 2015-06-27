fs = require 'fs'
path = require "path"
logger = require './../tools/logger'
Parse = require('parse').Parse
Q = require 'q'

class DataStorage

  constructor: (configs) ->
    Parse.initialize(
      configs.applicationId,
      configs.javascriptKey
    )

  ###
  className = 'className'
  data = {key: value}
  returns a promise
  ###
  insert: (className, data) ->
    deferred = Q.defer()
    deferred.reject null if not data?

    Object = Parse.Object.extend className
    insert = new Object()
    insert.save(data)
    .then (result) ->
      deferred.resolve result.id
    , (error) ->
      deferred.reject null

    deferred.promise

  ###
  className = 'className'
  id = 'lala'
  returns promise
  ###
  find: (className, equalToArray) ->
    deferred = Q.defer()

    Object = Parse.Object.extend className

    query = new Parse.Query Object
    equalToArray.forEach (select) ->
      {key, value} = select
      query.equalTo key, value

    query.find().then (results) ->
      deferred.reject null if results?.length is 0
      deferred.resolve results
    , (error) ->
      deferred.reject null

    deferred.promise

  findById: (className, id) ->
    deferred = Q.defer()

    Object = Parse.Object.extend className
    query = new Parse.Query Object
    query.get(id)
    .then (result) ->
      deferred.resolve result
    , (error) ->
      deferred.reject null

    deferred.promise

  ###
  className = 'className'
  id = 'lalala'
  data = {...}, e.g. {action: 'update'}
  ###
  update: (className, id, data) ->
    deferred = Q.defer()

    data.id = id
    @insert(className, data)
    .then (result) ->
      deferred.resolve result
    .catch deferred.reject

    deferred.promise

  ###
  className = 'className'
  objectId = 'lalala'
  returns promise
  ###
  delete: (className, id) ->
    deferred = Q.defer()

    @findById(className, id)
    .then (result) ->
      return deferred.resolve null if not result?
      result.destroy()
    .then (result) ->
      deferred.resolve result.id
    , (error) ->
      deferred.reject null
    .catch (error) ->
      deferred.reject null

    deferred.promise

  deleteAll: (className) ->
    deferred = Q.defer()

    query = new Parse.Query(className)
    query.find()
    .then (results) ->
      Parse.Object.destroyAll(results)
    , (error) ->
      deferred.reject null

    deferred.promise

  log: (className, code) ->
    deferred = Q.defer()

    Log = Parse.Object.extend className
    log = new Log()

    @createUser('Users', code)
    .then (user) ->
      log.set 'parent', {id: user.id}
      log.save null,
        success: (result) ->
          deferred.resolve result
        error: (result, error) ->
          deferred.reject null

    deferred.promise


  ###
  Creates a new user based on code or selects existing user if the code already registered
  Input: code = 'blah'
  Returns: a promise of a user object
  ###
  createUser: (className, code) ->
    deferred = Q.defer()

    @find className, [{key:'code', value:code}]
    .then (results) ->
      deferred.resolve results[0] if results?.length > 0
    .catch (error) ->
      User = Parse.Object.extend className
      user = new User()
      user.set 'code', code
      user.set 'logs', []

      user.save null,
        success: (result) ->
          deferred.resolve result
        error: (result, error) ->
          deferred.reject null

    deferred.promise

module.exports = DataStorage
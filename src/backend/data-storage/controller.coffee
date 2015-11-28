fs = require 'fs'
path = require "path"
logger = require './../tools/logger'
Parse = require('parse').Parse
Q = require 'q'
nowTimestamp = require './../tools/now'

class DataStorage

  constructor: (configs) ->

    @error = false

    parseConfigs = configs?.parse

    @error = true if \
      not configs? or not parseConfigs? or \
      not parseConfigs.applicationId or \
      not parseConfigs.javascriptKey or \
      not configs.className?.logs or \
      not configs.className?.users

    if @error
      return logger.error(
        'Error when initializing data controller'
      )
    logger.info 'Data controller initialized correctly'

    Parse.initialize(
      parseConfigs.applicationId,
      parseConfigs.javascriptKey
    )

    @className = configs.className

  ###
  className = 'className'
  data = {key: value}
  returns a promise
  ###
  insert: (className, data) ->
    return null if @error

    deferred = Q.defer()

    Object = Parse.Object.extend className
    insert = new Object()

    insert.save(data)
    .then (result) ->
      logger.debug "Data inserted to #{className}: #{JSON.stringify data}"
      deferred.resolve result
    , (error) ->
      deferred.reject null

    deferred.promise

  ###
  className = 'className'
  id = 'lala'
  returns promise
  ###
  find: (className, equalToArray) ->
    return null if @error

    deferred = Q.defer()

    Object = Parse.Object.extend className

    query = new Parse.Query Object
    equalToArray.forEach (equalTo) ->
      {key, value} = equalTo
      query.equalTo key, value

    query.find()
    .then (results) ->
      logger.debug "Data found in #{className}: #{JSON.stringify results}"
      deferred.resolve results or []
    , (error) ->
      deferred.resolve []

    deferred.promise

  findById: (className, id) ->
    return null if @error

    deferred = Q.defer()

    Object = Parse.Object.extend className
    query = new Parse.Query Object
    query.get(id)
    .then (result) ->
      logger.debug "Data found in #{className}: #{JSON.stringify result}"
      deferred.resolve result
    , (result, error) ->
      deferred.resolve null

    deferred.promise

  ###
  find latest entries inn className
  Input:
    className = 'className'
    count = <number>
  returns a promise (array of latest entries)
  ###
  findLatest: (className, equalToArray = [], limit = 1) ->
    return null if @error

    deferred = Q.defer()

    Object = Parse.Object.extend className

    query = new Parse.Query Object
    equalToArray.forEach (equalTo) ->
      {key, value} = equalTo
      query.equalTo key, value
    query.descending "createdAt"
    query.limit limit

    query.find()
    .then (results) ->
      logger.debug "Data found in #{className}: #{JSON.stringify results}"
      deferred.resolve results or []
    , (error) ->
      deferred.resolve []

    deferred.promise

  ###
  className = 'className'
  id = 'lalala'
  data = {...}, e.g. {action: 'update'}
  ###
  update: (className, id, data) ->
    return null if @error
    deferred = Q.defer()

    Object = Parse.Object.extend className
    object = new Object()
    object.id = id

    object.save(data).then =>
      @findById(className, id).then (result) ->
        deferred.resolve result
    , (error)->
      deferred.reject null

    deferred.promise

  ###
  className = 'className'
  objectId = 'lalala'
  returns promise
  ###
  delete: (className, id) ->
    return null if @error

    deferred = Q.defer()

    @findById(className, id)
    .then (result) ->
      return deferred.resolve null if not result?
      result.destroy()
    .then (result) ->
      logger.debug "Data deleted in #{className}: #{JSON.stringify result}"
      deferred.resolve result
    , (error) ->
      deferred.reject null
    .catch (error) ->
      deferred.reject null

    deferred.promise

  deleteAll: (className) ->
    return null if @error
    deferred = Q.defer()

    query = new Parse.Query(className)
    query.find()
    .then (results) ->
      logger.debug "All data deleted in #{className}: #{JSON.stringify results}"
      Parse.Object.destroyAll(results)
    , (error) ->
      deferred.reject null

    deferred.promise

  ###
  Creates a new user based on code or selects existing user if the code already registered
  Input: code = 'blah'
  Returns: a promise of a user object
  ###
  getUser: (code) ->
    return null if @error

    deferred = Q.defer()

    @find @className.users, [{key:'code', value:code}]
    .then (results) =>
      return deferred.resolve results[0] if results?.length > 0
      data =
        code: code
      @insert @className.users, data
      .then deferred.resolve
      .catch deferred.reject

    deferred.promise

  ###
  Log an enter/exit event
  Input: code = 'blah'
  Output:
    - it creates a new user and links the user with the input code
    - returns a promise (a log object which has a parent attribute)
  ###
  log: (code) ->
    return null if @error

    _parentId = null

    @getUser(code)
    .then (user) =>
      _parentId = user.id
      @findLatest @className.logs, [{key:'parentId',value:_parentId}]
    .then (logs) =>
      # set enterTime when user enters
      # set exitTime when user exits
      log = logs?[0] or null
      timestamp = nowTimestamp()
      if not log or log.get('exitTime')?
        return @insert @className.logs, {enterTime: timestamp, parentId: _parentId}
      @update @className.logs, log.id, {exitTime: timestamp}

module.exports = DataStorage
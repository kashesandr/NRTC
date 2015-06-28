fs = require 'fs'
path = require "path"
logger = require './../tools/logger'
Parse = require('parse').Parse
Q = require 'q'

class DataStorage

  constructor: (configs) ->

    @error = false

    parseConfigs = configs?.parse

    error = true if \
      not configs? or not parseConfigs? or \
      not parseConfigs.applicationId or \
      not parseConfigs.javascriptKey or \
      not configs.className?.logs or \
      not configs.className?.users

    if error
      @error = true
      return logger.error(
        'Error when initializing data controller'
      )

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

    data.id = id
    @insert className, data

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
      Parse.Object.destroyAll(results)
    , (error) ->
      deferred.reject null

    deferred.promise

  ###
  Creates a new user based on code or selects existing user if the code already registered
  Input: code = 'blah'
  Returns: a promise of a user object
  ###
  getUser: (className, code) ->
    return null if @error

    deferred = Q.defer()

    @find className, [{key:'code', value:code}]
    .then (results) =>
      deferred.resolve results[0] if results?.length > 0
      data =
        code: code
        logs: []
      @insert className, data
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
  log: (className, code) ->
    return null if @error

    _parentId = null
    @getUser 'Users', code
    .then (user) =>
      _parentId = user.id
      @findLatest className, [{key:'parentId',value:_parentId}]
    .then (logs) =>
      # the action should be 'exit'
      # if the entry before was ''enter'
      # otherwise it should be 'enter'
      log = logs[0] or null
      action = if log?.get('action') is 'enter' then 'exit' else 'enter'
      data =
        action: action
        parentId: _parentId
      @insert className, data

module.exports = DataStorage
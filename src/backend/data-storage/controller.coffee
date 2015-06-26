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
        insert.save data,
            success: (result) ->
                deferred.resolve result.id
            error: (result, error) ->
                deferred.reject error

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
            deferred.resolve results
        , (error) ->
            deferred.reject error

        deferred.promise

    findById: (className, id) ->
        deferred = Q.defer()

        Object = Parse.Object.extend className

        query = new Parse.Query Object
        query.get id,
            success: (result) ->
                deferred.resolve result
            error: (result, error) ->
                deferred.reject error

        deferred.promise



    ###
    className = 'className'
    id = 'lalala'
    data = {...}, e.g. {action: 'update'}
    ###
    update: (className, id, data) ->
        data.id = id
        @insert className, data

    ###
    className = 'className'
    objectId = 'lalala'
    returns promise
    ###
    delete: (className, id) ->
        deferred = Q.defer()

        @findById(className, id)
        .then (result) ->
            result.destroy
                success: (_result) ->
                    deferred.resolve _result.id
                error: (_result, error) ->
                    deferred.reject error
        .catch deferred.reject

        deferred.promise

    destroyAll: (className) ->
        deferred = Q.defer()

        query = new Parse.Query(className)
        query.find()
        .then (results) ->
            Parse.Object.destroyAll(results)
        , (error) ->
            deferred.reject error

        deferred.promise

    log: (className, code) ->
        deferred = Q.defer()

        Log = Parse.Object.extend className
        log = new Log()

        @createUser(code)
        .then (user) ->
            log.set 'parent', {id: user.id}
            log.save null,
                success: (result) ->
                    deferred.resolve result
                error: (result, error) ->
                    deferred.reject error

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

            return deferred.resolve results[0] if results?.length > 0

            User = Parse.Object.extend className, {
                # Instance properties go in an initialize method
                initialize: (attrs, options) ->

            }, {
                # Class methods
            }

            user = new User()
            user.set 'code', code
            user.set 'logs', []

            user.save null,
                success: (result) ->
                    deferred.resolve result
                error: (result, error) ->
                    deferred.reject error

        deferred.promise

module.exports = DataStorage
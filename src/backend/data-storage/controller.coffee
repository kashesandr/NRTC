fs = require 'fs'
path = require "path"
logger = require './../tools/logger'
Parse = require('node-parse-api').Parse
Q = require 'q'

class DataStorage

    constructor: (configs) ->
        @parseConfigs = configs.parse
        @table = configs.table
        @parseInstance = new Parse(
            @parseConfigs.applicationId,
            @parseConfigs.masterKey
        )

    ###
    table = 'SomeTable'
    data = {key: 'value'}
    returns promise
    ###
    insert: (table, data) ->
        deferred = Q.defer()
        @parseInstance.insert table, data, (error, response) ->
            deferred.reject "Error when inserting data: #{error}" if error
            deferred.resolve response?.objectId or null
        deferred.promise

    ###
    table = 'SomeTable'
    query = {...}, e.g. {objectId: 'lalala'}
    returns promise
    ###
    find: (table, query) ->
        deferred = Q.defer()
        @parseInstance.find table, query, (error, response) ->
            deferred.reject "Error when inserting data: #{error}" if error
            deferred.resolve response?.results or []
        deferred.promise

    ###
    table = 'SomeTable'
    objectId = 'lalala'
    data = {...}, e.g. {action: 'update'}
    ###
    update: (table, objectId, data) ->
        deferred = Q.defer()
        @parseInstance.update table, objectId, data, (error, response) ->
            deferred.reject "Error when updating data: #{error}" if error
            deferred.resolve data
        deferred.promise

    ###
    table = 'SomeTable'
    objectId = 'lalala'
    returns promise
    ###
    delete: (table, objectId) ->
        deferred = Q.defer()
        @parseInstance.delete table, objectId, (error, response) ->
            deferred.reject "Error when updating data: #{error}" if error
            deferred.resolve objectId
        deferred.promise

    log: (code) ->
        deferred = Q.defer()

        @.find('Users', {code: code})
        .then (results) ->
            user = results?[0] or null
            if not user?
                @createUser(code)
                .then (_user) ->
                    deferred.resolve _user
            else deferred.resolve user

        deferred.promise


    createUser: (code) ->
        deferred = Q.defer()
        user = Parse.Object.extend 'User', {
            # Instance properties go in an initialize method
            initialize: (attrs, options) ->
                this.code = code
                this.name = ''
                this.surname = ''
                this.log = []
        }, {
            # Class methods
        }
        user.increment('uid')
        user.save()
        deferred.promise

module.exports = DataStorage
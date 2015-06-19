fs = require 'fs'
path = require "path"
logger = require './../logger'
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

    insert: (table, data) ->
        deferred = Q.defer()
        @parseInstance.insert table, data, (error, response) ->
            deferred.reject "Error when inserting data: #{error}" if error
            deferred.resolve "Data inserted, response: #{response}"

    update: (table, objectId, data) ->
        deferred = Q.defer()
        @parseInstance.update table, objectId, data, (error, response) ->
            deferred.reject "Error when updating data: #{error}" if error
            deferred.resolve "Data updated, response: #{response}"

    log: (code) ->
        @createUser(code)
        .then (userId) ->


    createUser: (code) ->
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

module.exports = DataStorage
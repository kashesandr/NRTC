fs = require 'fs'
path = require "path"
logger = require './../logger'
Parse = require('node-parse-api').Parse
CONFIGS = JSON.parse fs.readFileSync (path.join(__dirname,'..','settings.json')), 'utf8'
moment = require 'moment'
Q = require 'q'

PARSE_CONFIGS = CONFIGS.PARSE
TABLE = CONFIGS.DATABASE.table

parseInstance = new Parse PARSE_CONFIGS.applicationId, PARSE_CONFIGS.masterKey

DataStorage = {}

DataStorage.insert = (table, data) ->
    deferred = Q.defer()
    parseInstance.insert table, data, (error, response) ->
        if error
            logger.error "DataStorage: Error when inserting data: #{error}"
            deferred.reject error
        logger.info "DataStorage: Data inserted into the '#{table}' table"
        deferred.resolve response

DataStorage.update = (table, objectId, data) ->
    deferred = Q.defer()
    parseInstance.update table, objectId, data, (error, response) ->
        if error
            logger.error "DataStorage: Error when updating data: #{error}"
            deferred.reject error
        logger.info "DataStorage: Data updated in the '#{table}' table"
        deferred.resolve response

DataStorage.historyLog = (code) ->
    table = TABLE.history
    now = moment().toDate()
    parseInstance.find table, {code: code, timeExit: null}, (error, response) ->
        logger.error "Parse: Error when historyLog(): #{error}" if error
        result = response?.results?[0] || null
        if (result)
            DataStorage.update table, result.objectId,
                code: result.code
                timeExit: now
        else
            DataStorage.insert table,
                code: code
                timeEnter: now
                timeExit: null

DataStorage.log = (code) ->

DataStorage.createUser = (code) ->


module.exports = DataStorage
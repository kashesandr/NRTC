fs = require 'fs'
path = require "path"
winston = require 'winston'
Parse = require('node-parse-api').Parse
CONFIGS = JSON.parse fs.readFileSync (path.join(__dirname,'..','settings.json')), 'utf8'
moment = require 'moment'

PARSE_CONFIGS = CONFIGS.PARSE
ParseInstance = new Parse(PARSE_CONFIGS.applicationId, PARSE_CONFIGS.masterKey)
TABLE = CONFIGS.DATABASE.table
lock = false

DbController = {}

DbController.insert = (table, what) ->
    return if lock is true
    lock = true
    ParseInstance.insert table, what, (error, response) ->
        return winston.error "Parse: Error occurred when inserting data to Parse: #{error}" if error
        winston.info "Parse: Data inserted into the '#{table}' table"
        lock = false

DbController.update = (table, objectId, data) ->
    return if lock is true
    lock = true
    ParseInstance.update table, objectId, data, (error) ->
        return winston.error "Parse: Error when update() in the table '#{table}': #{error}" if error
        winston.info "Parse: Data updated in the '#{table}' table"
        lock = false

DbController.historyLog = (code) ->
    table = TABLE.history
    now = moment().toDate()
    ParseInstance.find table, {code: code, timeExit: null}, (error, response) ->
        winston.error "Parse: Error when historyLog(): #{error}" if error
        result = response?.results?[0] || null
        if (result)
            DbController.update table, result.objectId,
                code: result.code
                timeExit: now
        else
            DbController.insert table,
                code: code
                timeEnter: now
                timeExit: null

module.exports = DbController
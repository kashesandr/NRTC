fs = require 'fs'
Parse = require('node-parse-api').Parse
Configs = require "./configs"
GlobalConfigs = JSON.parse fs.readFileSync './../settings.json', 'utf8'
moment = require 'moment'

PARSE = GlobalConfigs.GLOBAL_CONFIGS.parse
Parse = new Parse(PARSE.applicationId, PARSE.masterKey)
TABLE = GlobalConfigs.GLOBAL_CONFIGS.database.table
lock = false

DbController = {}

DbController.insert = (table, what) ->
    return if lock is true
    lock = true
    Parse.insert table, what, (error, response) ->
        return console.log "Parse: Error occurred when inserting data to Parse: #{error}" if error
        console.log "Parse: Data inserted into the '#{table}' table"
        lock = false

DbController.update = (table, objectId, data) ->
    return if lock is true
    lock = true
    Parse.update table, objectId, data, (error) ->
        return console.log "Parse: Error when update() in the table '#{table}': #{error}" if error
        console.log "Parse: Data updated in the '#{table}' table"
        lock = false

DbController.historyLog = (code) ->
    table = TABLE.history
    now = moment().toDate()
    Parse.find table, {code: code, timeExit: null}, (error, response) ->
        console.log "Parse: Error when historyLog(): #{error}" if error
        result = response?.results?[0] || null
        if (result)
            DbController.update table, result.objectId, {
                code: result.code
                timeExit: now
            }
        else
            DbController.insert table, {
                code: code
                timeEnter: now
                timeExit: null
            }

module.exports = DbController
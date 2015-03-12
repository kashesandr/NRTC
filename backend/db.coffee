fs = require 'fs'
Parse = require('node-parse-api').Parse
Configs = require "./configs"
GlobalConfigs = JSON.parse fs.readFileSync './../settings.json', 'utf8'
parse = new Parse(GlobalConfigs.parse.applicationId, GlobalConfigs.parse.masterKey)
DB = {}

DB.insert = (where, what) ->
    parse.insert where, what, (error, response) ->
        return console.log "Parse: Error occurred when inserting data to Parse" if error
        console.log "Parse: Data inserted"

DB.update = (where, id, what) ->
    parse.update where, id, what, (error) ->
        return console.log "Parse: Error when update()" if error
        console.log "Parse: Data updated" if error

DB.toggleActive = (where, what) ->
    parse.find where, what, (error, response) ->
        results = response?.results
        return console.log "Parse: Error when toggleActive()" if error
        if (results?.length is 0)
            DB.insert where,{
                code: what.code,
                active: true
            }
        else
            DB.update where, results[0].objectId, {
                code: what.code
                active: !results[0].active
            }

module.exports = DB
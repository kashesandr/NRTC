'use strict'

nrtc = angular

.module 'NRTC', ['parse-angular', 'angularMoment', 'ui.bootstrap', 'GlobalConfigs']

.config (GLOBAL_CONFIGS)->
    PARSE_CONFIGS = GLOBAL_CONFIGS.PARSE
    Parse.initialize PARSE_CONFIGS.applicationId, PARSE_CONFIGS.javascriptKey

.factory 'UPDATE_TIMEOUT', (GLOBAL_CONFIGS) ->
    return GLOBAL_CONFIGS.UPDATE_TIMEOUT_MILLISECONDS

.factory 'PRICE_RULES', (GLOBAL_CONFIGS) ->
    ###
    [
      {
        "start": 0,
        "end": 5,
        "pricePerMinute": 2
      },
      ...
    ]
    ###
    return GLOBAL_CONFIGS.PRICE_RULES.map (item) ->
        item.start = parseFloat item.start
        item.end = parseFloat item.end
        item

.constant 'CONSTANTS', {
    ONLINE_COUNT: 50,
    LOGS_COUNT: 50
}

.run ($rootScope, dataService, UPDATE_TIMEOUT, CONSTANTS) ->

    updating = true

    $rootScope.$on "updating", (e, val) ->
        updating = val
        if val is true
            $rootScope.$emit 'users-online:load'
            $rootScope.$emit 'logs:load'

    $rootScope.$on "users-online:loaded", ->
        return unless updating
        window.setTimeout ->
            $rootScope.$emit 'users-online:load'
        , UPDATE_TIMEOUT
    $rootScope.$emit 'users-online:load', CONSTANTS.ONLINE_COUNT

    $rootScope.$on "logs:loaded", ->
        return unless updating
        window.setTimeout ->
            $rootScope.$emit 'logs:load'
        , UPDATE_TIMEOUT
    $rootScope.$emit 'logs:load', CONSTANTS.LOGS_COUNT

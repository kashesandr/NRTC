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

.run ($rootScope, dataService, UPDATE_TIMEOUT) ->

    updatingLogs = true

    $rootScope.$on "logs:updating", (e, val) ->
        updatingLogs = val
        $rootScope.$emit 'logs:load' if val is true

    $rootScope.$on "logs:loaded", ->
        return unless updatingLogs
        window.setTimeout ->
            $rootScope.$emit 'logs:load'
        , UPDATE_TIMEOUT

    $rootScope.$emit 'logs:load'

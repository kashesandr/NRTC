'use strict'

nrtc = angular

.module 'NRTC', ['parse-angular', 'angularMoment', 'ui.bootstrap', 'GlobalConfigs']

.config (GLOBAL_CONFIGS)->
    PARSE_CONFIGS = GLOBAL_CONFIGS.PARSE
    Parse.initialize PARSE_CONFIGS.applicationId, PARSE_CONFIGS.javascriptKey

.constant 'PRICE',
    "discountPeriodInMinutes": 60,
    "priceBefore": 2,
    "priceAfter": 1

.constant 'UPDATE_TIMEOUT', 1000

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

'use strict'

nrtc = angular

.module 'NRTC', ['parse-angular', 'angularMoment', 'ui.bootstrap', 'GlobalConfigs']

.config (GLOBAL_CONFIGS)->
    PARSE_CONFIGS = GLOBAL_CONFIGS.parse
    Parse.initialize PARSE_CONFIGS.applicationId, PARSE_CONFIGS.javascriptKey

.constant 'PRICE',
    "discountPeriodInMinutes": 60,
    "priceBefore": 2,
    "priceAfter": 1

.constant 'UPDATE_TIMEOUT', 1000

.run ($rootScope, dataService, UPDATE_TIMEOUT) ->

    $rootScope.$on "historyLoaded", ->
        window.setTimeout ->
            dataService.historyLoad(100)
        , UPDATE_TIMEOUT

    dataService.historyLoad()

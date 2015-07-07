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

    $rootScope.$on "usersLoaded", ->
        window.setTimeout ->
            $rootScope.$emit 'usersLoad'
        , UPDATE_TIMEOUT

    $rootScope.$emit 'usersLoad'

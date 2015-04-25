'use strict'

nrtc = angular
.module('NRTC', ['parse-angular', 'angularMoment', 'ui.bootstrap', 'GlobalConfigs'])
.config( (GLOBAL_CONFIGS)->
    PARSE_CONFIGS = GLOBAL_CONFIGS.parse
    Parse.initialize PARSE_CONFIGS.applicationId, PARSE_CONFIGS.javascriptKey
)
.constant('PRICE', {
    "discountPeriodInMinutes": 60,
    "priceBefore": 2,
    "priceAfter": 1
})
.run( ($rootScope, dataService) ->
    dataService.getHistory()
    window.setInterval ->
        dataService.getHistory(100)
    , 1000

)
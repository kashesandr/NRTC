'use strict'

nrtc = angular
.module('NRTC', ['parse-angular', 'angularMoment', 'ui.bootstrap', 'GlobalConfigs'])
.config( (GLOBAL_CONFIGS)->
    parseConfigs = GLOBAL_CONFIGS.parse
    Parse.initialize parseConfigs.applicationId, parseConfigs.javascriptKey
)
.run( ($rootScope, dataService) ->
    dataService.getHistory()
    window.setInterval ->
        dataService.getHistory(25)
    , 1000

)
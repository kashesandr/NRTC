'use strict'

nrtc = angular
.module('NRTC', ['parse-angular', 'angularMoment', 'ui.bootstrap'])
.config(->
    Parse.initialize "2Wmev3bHSMdsvl7vfJKVWSl9VcMvg5dU1uGVBeMO", "g7N28dVW3zroZBa8tjEpfNQQtRNyMVym0PeEVEr4"
)
.run( ($rootScope, dataService) ->
    dataService.getHistory()
    dataService.getActiveUsers()
    window.setInterval ->
        dataService.getHistory(25)
        dataService.getActiveUsers()
    , 1000

)
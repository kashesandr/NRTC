nrtc = angular.module 'NRTC'

nrtc.controller "nrtcController", ($rootScope, $scope, PRICE_RULES, CONSTANTS) ->

    $scope.logs = []
    $scope.editMode = false
    $scope.onlineCount = CONSTANTS.ONLINE_COUNT
    $scope.logsCount = CONSTANTS.LOGS_COUNT

    $scope.$watch "editMode", (oldVal, newVal) ->
        return if oldVal is newVal
        $scope.$emit "updating", newVal

    $scope.$on "logs:loaded", (e, data) ->
        $scope.logs = data.map (log) ->
            durationSeconds = $scope._getDurationSeconds(log.exitTime, log.enterTime)
            log.isOnline = not log.exitTime?
            log.durationSeconds = durationSeconds
            log.price = $scope._getPrice(durationSeconds)
            log

    $scope.$on "users-online:loaded", (e, data) ->
        $scope.online = data.map (item) ->
            durationSeconds = $scope._getDurationSeconds(item.exitTime, item.enterTime)
            item.isOnline = not item.exitTime?
            item.durationSeconds = durationSeconds
            item.price = $scope._getPrice(durationSeconds)
            item

    $scope.logDelete = (id) ->
        $rootScope.$broadcast 'log:delete', id

    $scope.$on "log:deleted", ->
        $scope.editMode = false

    ###
    helper functions
    expose them so they might be tested some day...
    ###

    ###
    Apply rules so we may calculate the price
    PRICE_RULES = [
      {
        "periodStart": 0,
        "periodEnd": 5,
        "secondsInPeriod": 60,
        "pricePerPeriod": 2
      },
      ...
    ]

    input value in seconds
    ###
    $scope._getPrice = (value) ->
        result = 0

        for item, i in PRICE_RULES
            if value <= item.periodStartSeconds
                continue
            x = if value < item.periodEndSeconds \
                then value - item.periodStartSeconds \
                else item.periodEndSeconds - item.periodStartSeconds
            result += item.pricePerPeriod * Math.ceil(x / item.secondsInPeriod)
    
        result

    $scope._getDurationSeconds = (exitTime, enterTime) ->
        exitTime ?= (new Date()).getTime()
        return Math.round (exitTime - enterTime)/1000

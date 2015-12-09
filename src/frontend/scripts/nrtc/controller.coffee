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
            durationMinutes = $scope._getDurationMinutes(log.exitTime, log.enterTime)
            log.isOnline = not log.exitTime?
            log.durationMinutes = durationMinutes
            log.price = $scope._getPriceFromMinutes(durationMinutes)
            log

    $scope.$on "users-online:loaded", (e, data) ->
        $scope.online = data.map (item) ->
            durationMinutes = $scope._getDurationMinutes(item.exitTime, item.enterTime)
            item.isOnline = not item.exitTime?
            item.durationMinutes = durationMinutes
            item.price = $scope._getPriceFromMinutes(durationMinutes)
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
        "pricePerMinute": 1,
        "afterMinutes": 0
      }
    ]
    ###
    $scope._getPriceFromMinutes = (value) ->
        result = 0
        x = 0
        PRICE_RULES.forEach (item, i) ->
            x = if value < item.end \
                then value \
                else item.end
            result += item.pricePerMinute * x

        result

    $scope._getDurationMinutes = (exitTime, enterTime) ->
        exitTime ?= (new Date()).getTime()
        return Math.round (exitTime - enterTime)/1000/60

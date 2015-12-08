nrtc = angular.module 'NRTC'

nrtc.controller "nrtcController", ($rootScope, $scope, PRICE_RULES) ->

    $scope.logs = []
    $scope.editMode = false

    $scope.$watch "editMode", (oldVal, newVal) ->
        return if oldVal is newVal
        $scope.$emit "logs:updating", newVal

    $scope.$on "logs:loaded", (e, data) ->
        $scope.logs = data.map (log) ->
            durationMinutes = $scope._getDurationMinutes(log.exitTime, log.enterTime)

            log.isOnline = if log.exitTime then false else true
            log.durationMinutes = durationMinutes
            log.price = $scope._getPriceFromMinutes(durationMinutes)
            log

    $scope.logDelete = (id) ->
        $rootScope.$broadcast 'logDelete', id

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

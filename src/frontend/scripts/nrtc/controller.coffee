nrtc = angular.module 'NRTC'

nrtc.controller "nrtcController", ($rootScope, $scope, PRICE_RULES) ->

    $scope.logs = []
    $scope.editMode = false
    rules = PRICE_RULES

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
    ###
    $scope._getPriceFromMinutes = (value) ->
        # if value < lower range bound
        # if value within the bounds
        # if value > max range bound
        value

    $scope._getDurationMinutes = (exitTime, enterTime) ->
        exitTime ?= (new Date()).getTime()
        return Math.round (exitTime - enterTime)/1000/60

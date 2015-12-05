nrtc = angular.module 'NRTC'

nrtc.controller "nrtcController", ($rootScope, $scope, PRICE) ->

    $scope.logs = []
    $scope.editMode = false

    $scope.$watch "editMode", (oldVal, newVal) ->
        return if oldVal is newVal
        $scope.$emit "logs:updating", newVal

    $scope.$on "logs:loaded", (e, data) ->
        $scope.logs = data.map (log) ->
            log.isOnline = if log.exitTime then false else true
            log.durationInMinutes = 0
            log.price = 0
            log.fullname = ''
            log

    $scope.logDelete = (id) ->
        $rootScope.$broadcast 'logDelete', id
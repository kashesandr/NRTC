nrtc = angular.module 'NRTC'

nrtc.controller "nrtcController", ($rootScope, $scope, PRICE) ->

    $scope.logs = []

    $scope.$on "logsLoaded", (e, data) ->
        $scope.logs = data.map (log) ->
            log.isOnline = if log.exitTime then false else true
            log.durationInMinutes = 0
            log.price = 0
            log

    $scope.logDelete = (id) ->
        $rootScope.$broadcast 'logDelete', id
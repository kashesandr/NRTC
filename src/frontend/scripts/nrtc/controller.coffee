nrtc = angular.module 'NRTC'

nrtc.controller "nrtcController", ($rootScope, $scope, PRICE) ->

    $scope.data = {}

    $scope.$on "usersLoaded", (e, data) ->

        $scope.entries = data.map (user) ->

            exports = {
                code: user.code
                isOnline: user.isOnline
                timeEnter: null
                timeExit: null
                durationInMinutes: null
                price: null
            }

    $scope.logDelete = (id) ->
        $rootScope.$broadcast 'logDelete', id
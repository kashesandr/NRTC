nrtc = angular.module 'NRTC'

nrtc.controller "nrtcController", ($scope) ->
    $scope.data = {}
    $scope.$on "historyLoaded", (e, data) ->
        $scope.data.history = data
    $scope.$on "activeUsersLoaded", (e, data) ->
        $scope.data.activeUsers = data.filter (item)->
            item.active is true
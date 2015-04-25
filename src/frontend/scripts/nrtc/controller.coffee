nrtc = angular.module 'NRTC'

nrtc.controller "nrtcController", ($scope, PRICE) ->
    $scope.data = {}
    $scope.$on "historyLoaded", (e, data) ->
        data.forEach (card) ->

            durationInMinutes = moment(card.timeExit || new Date()).diff(moment(card.timeEnter), 'minutes')
            price = if (durationInMinutes < PRICE.discountPeriodInMinutes)\
                then durationInMinutes*PRICE.priceBefore\
                else PRICE.discountPeriodInMinutes*(PRICE.priceBefore-PRICE.priceAfter)+durationInMinutes*PRICE.priceAfter

            card.durationInMinutes = durationInMinutes || 0
            card.price = price || 0
            card.isOnline = card.timeExit is null

        $scope.data = data
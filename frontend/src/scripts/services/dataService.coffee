nrtc = angular.module 'NRTC'

nrtc.factory "dataService", ($rootScope) ->
    getHistory = (count) ->
        query = new Parse.Query('History')
        query.limit(count || 10).find({
            success: (data) ->
                $rootScope.$broadcast 'historyLoaded', data.map((item)->
                    date: item.createdAt
                    code: item.get 'code'
                    id: item.id
                )
            error: (error) ->
                $rootScope.$broadcast 'error', error
        })
    getActiveUsers = ->
        query = new Parse.Query('Tags')
        query.find({
            success: (data) ->
                $rootScope.$broadcast 'activeUsersLoaded', data.map((item)->
                    date: item.updatedAt
                    code: item.get 'code'
                    active: item.get 'active'
                    id: item.id
                )
            error: (error) ->
                $rootScope.$broadcast 'error', error
        })
    exports = {
        getHistory
        getActiveUsers
    }
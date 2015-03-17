nrtc = angular.module 'NRTC'

nrtc.factory "dataService", ($rootScope, GLOBAL_CONFIGS) ->
    dbConfigs = GLOBAL_CONFIGS.database
    getHistory = (count) ->
        query = new Parse.Query dbConfigs.table.history
        query.limit(count || 10).find({
            success: (data) ->
                $rootScope.$broadcast 'historyLoaded', data.map((item)->
                    code: item.get 'code'
                    id: item.id
                    timeEnter: item.get 'timeEnter'
                    timeExit: item.get 'timeExit'
                )
            error: (error) ->
                $rootScope.$broadcast 'error', error
        })
    exports = {
        getHistory
    }
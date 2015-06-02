nrtc = angular.module 'NRTC'

nrtc.factory "dataService", ($rootScope, GLOBAL_CONFIGS) ->

    DB_CONFIGS = GLOBAL_CONFIGS.database

    historyLoad = (count) ->
        query = new Parse.Query DB_CONFIGS.table.history
        query.descending("updatedAt")
        .limit(count || 10)
        .find
            success: (data) ->
                $rootScope.$broadcast 'historyLoaded', data.map (item)->
                    id: item.id
                    code: item.get 'code'
                    updatedAt: item.updatedAt
                    timeEnter: item.get 'timeEnter'
                    timeExit: item.get 'timeExit'
            error: (error) ->
                $rootScope.$broadcast 'error', error

    cardDelete = (id) ->

        query = new Parse.Query DB_CONFIGS.table.history

        query.get id,
            success: (data) ->
                data.destroy({})
            error: (error) ->
                $rootScope.$broadcast 'error', error

    $rootScope.$on 'cardDelete', (e, id) ->
        cardDelete id

    exports = {
        historyLoad
        cardDelete
    }
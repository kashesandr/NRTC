nrtc = angular.module 'NRTC'

nrtc.factory "dataService", ($rootScope, GLOBAL_CONFIGS) ->

    DB_CONFIGS = GLOBAL_CONFIGS.DATABASE

    exports =

        logsLoad : (count = 10) ->
            query = new Parse.Query DB_CONFIGS.className.logs
            query.descending("createdAt")
            .limit(count)
            .find
                success: (data) ->
                    $rootScope.$broadcast 'logsLoaded', data.map (item)->
                        id: item.id
                        code: item.get 'code'
                        parentId: item.get 'parentId'
                        action: item.get 'action'
                        createdAt: item.createdAt
                error: (error) ->
                    $rootScope.$broadcast 'error', error

        logDelete : (id) ->
            query = new Parse.Query DB_CONFIGS.className.logs
            query.get id,
                success: (data) ->
                    $rootScope.$emit 'logDeleted', id
                    data.destroy({})
                error: (error) ->
                    $rootScope.$broadcast 'error', error

        usersLoad : (count = 10) ->
            query = new Parse.Query DB_CONFIGS.className.users
            query
            .equalTo('isOnline', true)
            .limit(count)
            .find
                success: (data) ->
                    $rootScope.$broadcast 'usersLoaded', data.map (item)->
                        id: item.id
                        code: item.get 'code'
                        isOnline: item.get 'isOnline'
                error: (error) ->
                    $rootScope.$broadcast 'error', error

    # add events
    for funcName, func of exports
        $rootScope.$on funcName, (e, param) ->
            func param

    exports
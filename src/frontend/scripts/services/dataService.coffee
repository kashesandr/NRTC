nrtc = angular.module 'NRTC'

nrtc.factory "dataService", ($rootScope, GLOBAL_CONFIGS) ->

    DB_CONFIGS = GLOBAL_CONFIGS.DATABASE
    exports = {}

    $rootScope.$on 'users-online:load', (e, count) ->
        exports.usersOnlineLoad count

    $rootScope.$on 'logs:load', (e, count) ->
        exports.logsLoad count

    $rootScope.$on 'log:delete', (e, id) ->
        exports.logDelete id

    exports =

        usersOnlineLoad: (count = 50) ->
            query = new Parse.Query DB_CONFIGS.className.logs
            query
            .doesNotExist("exitTime")
            .descending("enterTime")
            .limit(count)
            .find
                success: (data) ->
                    $rootScope.$broadcast 'users-online:loaded', data.map (item)->
                        id: item.id
                        parentId: item.get 'parentId'
                        enterTime: item.get 'enterTime'
                        exitTime: item.get 'exitTime'
                        createdAt: item.createdAt
                        updatedAt: item.updatedAt
                error: (error) ->
                    $rootScope.$broadcast 'error', error

        logsLoad: (count = 50) ->
            query = new Parse.Query DB_CONFIGS.className.logs
            query
            .descending("updatedAt")
            .limit(count)
            .find
                success: (data) ->
                    $rootScope.$broadcast 'logs:loaded', data.map (item)->
                        id: item.id
                        parentId: item.get 'parentId'
                        enterTime: item.get 'enterTime'
                        exitTime: item.get 'exitTime'
                        createdAt: item.createdAt
                        updatedAt: item.updatedAt
                error: (error) ->
                    $rootScope.$broadcast 'error', error

        logDelete: (id) ->
            query = new Parse.Query DB_CONFIGS.className.logs
            query.get id,
                success: (data) ->
                    data.destroy({})
                    .then ->
                        $rootScope.$broadcast 'log:deleted', id
                error: (error) ->
                    $rootScope.$broadcast 'error', error

    exports
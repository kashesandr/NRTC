nrtc = angular.module 'NRTC'

nrtc.factory "dataService", ($rootScope, GLOBAL_CONFIGS) ->

    DB_CONFIGS = GLOBAL_CONFIGS.DATABASE

    exports =

        logsLoad: (count = 50) ->
            query = new Parse.Query DB_CONFIGS.className.logs
            query.descending("updatedAt")
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
                    $rootScope.$broadcast 'logDeleted', id
                    data.destroy({})
                error: (error) ->
                    $rootScope.$broadcast 'error', error

    $rootScope.$on 'logs:load', (e, param) ->
        exports.logsLoad param

    $rootScope.$on 'logDelete', (e, param) ->
        exports.logDelete param

    exports
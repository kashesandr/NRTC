nrtc = angular.module "NRTC"

nrtc.directive 'nrtcTable', () ->
    directive =
        replace: true
        restrict: 'EA'
        templateUrl: "scripts/nrtc-table/template.html"
        controller: "nrtcTableController"
        scope:
            model: "=ngModel"



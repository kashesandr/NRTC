nrtc = angular.module "NRTC"

nrtc.directive 'nrtc', () ->
    directive =
        templateUrl: "scripts/nrtc/template.html"
        controller: "nrtcController"

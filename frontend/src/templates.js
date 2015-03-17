(function() {
    'use strict';
    angular.module('NRTC').run(function($templateCache) {$templateCache.put("scripts/nrtc/template.html","<div class=\"row\"><div class=\"col-md-8 col-md-offset-2\"><h1>Time Control</h1><div class=\"row\"><div class=\"col-md-12\"><table class=\"table table-striped table-bordered table-hover table-condensed\"><thead><th>Code</th><th>Status</th><th>Enter Time</th><th>Exit Time</th><th>Duration (minutes)</th><th>Price</th></thead><tbody><tr ng-repeat=\"card in data | orderBy:\'timeExit\':true\"><td>{{card.code}}</td><td><span ng-class=\"{\'true\':\'label-success\',\'false\':\'label-default\'}[card.isOnline]\" class=\"label\">{{ {\'true\':\'Online\', \'false\':\'Offline\'}[card.isOnline] }}</span></td><td>{{card.timeEnter | amDateFormat:\'HH:mm:ss (MMMM D YYYY)\'}}</td><td>{{card.timeExit | amDateFormat:\'HH:mm:ss (MMMM D YYYY)\'}}</td><td><span ng-class=\"{\'true\':\'label-success\',\'false\':\'label-default\'}[card.isOnline]\" class=\"label\">{{card.durationInMinutes}}</span></td><td><span ng-class=\"{\'true\':\'label-success\',\'false\':\'label-default\'}[card.isOnline]\" class=\"label\">{{card.price}}</span></td></tr></tbody></table></div></div></div></div>");})}).call(this);
'use strict';

var angular = require('angular');

angular.module('calcentral.directives').directive('ccAcademicPlansDirective', [function() {
  return {
    templateUrl: 'directives/academic_plans.html',
    scope: {
      plans: '=',
      options: '=',
      type: '@'
    }
  };
}]);

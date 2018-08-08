'use strict';



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

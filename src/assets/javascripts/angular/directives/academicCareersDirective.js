'use strict';

var angular = require('angular');

angular.module('calcentral.directives').directive('ccAcademicCareersDirective', [function() {
  return {
    templateUrl: 'directives/academic_careers.html',
    scope: {
      careers: '='
    }
  };
}]);

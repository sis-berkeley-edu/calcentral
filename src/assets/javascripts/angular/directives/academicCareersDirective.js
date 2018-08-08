'use strict';



angular.module('calcentral.directives').directive('ccAcademicCareersDirective', [function() {
  return {
    templateUrl: 'directives/academic_careers.html',
    scope: {
      careers: '='
    }
  };
}]);

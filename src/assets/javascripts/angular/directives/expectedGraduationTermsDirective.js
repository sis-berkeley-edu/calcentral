'use strict';

angular.module('calcentral.directives').directive('ccExpectedGraduationTermsDirective', [function() {
  return {
    templateUrl: 'directives/expected_graduation_terms.html',
    scope: {
      termsInAttendance: '=',
      graduation: '=',
      isAdvisingStudentLookup: '='
    }
  };
}]);

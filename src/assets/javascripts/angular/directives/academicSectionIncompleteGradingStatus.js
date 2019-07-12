'use strict';

/**
 * Directive for displaying a sections incomplete grading status
 */
angular.module('calcentral.directives').directive('ccAcademicSectionIncompleteGradingStatus', function() {
  return {
    templateUrl: 'directives/academic_section_incomplete_grading_status.html',
    scope: {
      section: '=',
      academicGuideGradesPolicyLink: '='
    }
  };
});

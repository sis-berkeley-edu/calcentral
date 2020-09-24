'use strict';

/**
 * Directive for displaying a sections incomplete grading status
 *
 * Note: The SectionIncompleteGradingStatus component reproduces this row functionality.
 *
 * React2Angular components do not work properly within ng-repeat-start and ng-repeat-end loops
 *
 * TODO: Replace this directive with SectionIncompleteGradingStatus when possible.
 */
angular.module('calcentral.directives').directive('ccAcademicSectionIncompleteGradingStatus', function() {
  return {
    templateUrl: 'directives/academic_section_incomplete_grading_status.html',
    scope: {
      academicGuideGradesPolicyLink: '@',
      lapseDateDisplayColumnIndex: '@',
      frozenDisplayColumnIndex: '@',
      gradingLapseDeadline: '@',
      gradingLapseDeadlineDisplay: '@',
      gradingBasis: '@',
      totalColumns: '@',
    },
    link: function(scope, elem, attrs) {
      let academicGuideGradesPolicyLink = scope.$eval(attrs.academicGuideGradesPolicyLink);
      let frozenDisplayColumnIndex = scope.$eval(attrs.frozenDisplayColumnIndex);
      let lapseDateDisplayColumnIndex = scope.$eval(attrs.lapseDateDisplayColumnIndex);
      let totalColumns = scope.$eval(attrs.totalColumns);

      if (totalColumns) {
        scope.totalColumns = totalColumns;
        scope.columnIndexes = [...Array(totalColumns).keys()];
      } else {
        scope.totalColumns = 0;
        scope.columnIndexes = [];
      }
      scope.academicGuideGradesPolicyLink = academicGuideGradesPolicyLink;
      scope.showGradingLapseDeadline = (scope.gradingLapseDeadlineDisplay && scope.gradingLapseDeadline);
      scope.gradingBasisIsFrozen = (scope.gradingBasis === 'FRZ');
      scope.showSingleColumn = (scope.showGradingLapseDeadline && lapseDateDisplayColumnIndex === 0) || (scope.gradingBasisIsFrozen && frozenDisplayColumnIndex === 0);
      scope.displayColumnIndex = (scope.showGradingLapseDeadline && lapseDateDisplayColumnIndex) || (scope.gradingBasisIsFrozen && frozenDisplayColumnIndex);
    }
  };
});

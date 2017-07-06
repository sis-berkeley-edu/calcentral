/* jshint camelcase: false */
'use strict';

var angular = require('angular');
var _ = require('lodash');

/**
 * Academics GPA controller
 */
angular.module('calcentral.controllers').controller('AcademicsFinalGradesController', function($scope) {
  var hasGrades = function() {
    var hasGrades = false;
    var selectedCourses = $scope.selectedCourses;
    _.forEach(selectedCourses, function(course) {
      var sections = _.get(course, 'sections');

      _.forEach(sections, function(section) {
        if (section.is_primary_section && section.grading.grade) {
          hasGrades = true;
          // Lodash uses 'return false' to break from a loop.
          return false;
        }
      });

      // If we found a grade, break from the loop.
      if (hasGrades) {
        return false;
      }
    });
    return hasGrades;
  };

  $scope.semesterHasGrades = hasGrades();
});

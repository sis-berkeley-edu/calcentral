/* jshint camelcase: false */
'use strict';

var angular = require('angular');
var _ = require('lodash');

/**
 * Academics GPA controller
 */
angular.module('calcentral.controllers').controller('AcademicsGpaController', function($scope) {
  var gradeOptions = [
    {
      grade: 'A/A+',
      weight: 4
    },
    {
      grade: 'A-',
      weight: 3.7
    },
    {
      grade: 'B+',
      weight: 3.3
    },
    {
      grade: 'B',
      weight: 3
    },
    {
      grade: 'B-',
      weight: 2.7
    },
    {
      grade: 'C+',
      weight: 2.3
    },
    {
      grade: 'C',
      weight: 2
    },
    {
      grade: 'C-',
      weight: 1.7
    },
    {
      grade: 'D+',
      weight: 1.3
    },
    {
      grade: 'D',
      weight: 1
    },
    {
      grade: 'D-',
      weight: 0.7
    },
    {
      grade: 'F',
      weight: 0
    },
    {
      grade: 'P/NP',
      weight: -1
    }
  ];

  $scope.gradeOptions = gradeOptions;

  var findWeight = function(grade) {
    // Handle the discrepancy between transcript grades and menu options.
    if (grade === 'A' || grade === 'A+') {
      grade = 'A/A+';
    }
    var weight = gradeOptions.filter(function(element) {
      return element.grade === grade;
    });
    if (weight.length > 0) {
      return weight[0].weight;
    } else {
      // Do not include unrecognized grades in GPA calculations.
      return -1;
    }
  };

  var accumulateUnits = function(courses, accumulator) {
    var gradingSource;
    _.forEach(courses, function(course) {
      _.forEach(course.sections, function(section) {
        if (section.is_primary_section && section.grading.grade) {
          gradingSource = section.grading;
        } else if (section.is_primary_section && !section.grading.grade) {
          gradingSource = section.estimatedGrading;
        }
        if (gradingSource.units) {
          var grade;
          if (_.isNaN(gradingSource.grade)) {
            grade = findWeight(gradingSource.grade);
          } else {
            grade = gradingSource.grade;
          }
        }
        if ((grade || grade === 0) && grade !== -1) {
          gradingSource.score = parseFloat(grade, 10) * gradingSource.units;
          accumulator.units += parseFloat(gradingSource.units, 10);
          accumulator.score += gradingSource.score;
        }
      });
    });
    return accumulator;
  };

  var gpaCalculate = function() {
    // Recalculate GPA on every dropdown change.
    var selectedSemesterTotals = {
      'score': 0,
      'units': 0
    };
    accumulateUnits($scope.selectedCourses, selectedSemesterTotals);
    $scope.estimatedGpa = selectedSemesterTotals.score / selectedSemesterTotals.units;
    $scope.estimatedCumulativeGpa =
        (($scope.gpaUnits.cumulativeGpa * $scope.gpaUnits.totalUnitsAttempted) + selectedSemesterTotals.score) /
        ($scope.gpaUnits.totalUnitsAttempted + selectedSemesterTotals.units);
  };

  $scope.gpaUpdateCourse = function(sectionEstimatedGrading, estimatedGrade) {
    // Update course object on scope and recalculate overall GPA
    sectionEstimatedGrading.estimatedGrade = estimatedGrade;
    gpaCalculate();
  };

  var gpaInit = function() {
    if ($scope.selectedSemester.timeBucket !== 'past' || $scope.selectedSemester.gradingInProgress) {
      _.forEach($scope.selectedCourses, function(course) {
        _.forEach(course.sections, function(section) {
          if (section.is_primary_section && !section.grading.grade) {
            var gradingRow = {
              'gradeOption': section.grading.grading_basis,
              'units': section.units
            };
            if (gradingRow.gradeOption === 'GRD') {
              gradingRow.grade = 4;
            } else if (gradingRow.gradeOption === 'P/NP' || gradingRow.gradeOption === 'S/U' || gradingRow.gradeOption === 'C/NC') {
              gradingRow.grade = -1;
            }
            section.estimatedGrading = gradingRow;
          }
        });
      });
    }
    gpaCalculate();
  };

  gpaInit();
});

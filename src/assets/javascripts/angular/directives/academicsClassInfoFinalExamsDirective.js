/* jshint camelcase: false */
'use strict';

var angular = require('angular');
var _ = require('lodash');

angular.module('calcentral.directives').directive('ccAcademicsClassInfoFinalExamsDirective', function() {
  return {
    scope: true,
    link: function(scope, elem, attrs) {
      scope.courseHasSectionWithFinalExam = function() {
        if (scope.primarySections) {
          var matchFound = _.find(scope.primarySections, function(section) {
            return _.get(section, 'finalExams');
          });
          return !!matchFound;
        } else {
          return false;
        }
      };

      scope.$watch(
        function() {
          return scope.$eval(attrs.selectedCourse);
        },
        function(selectedCourse) {
          scope.primarySections = getCoursePrimarySections(selectedCourse);
        }
      );

      var getCoursePrimarySections = function(course) {
        var courseSections = _.get(course, 'sections');
        if (courseSections) {
          return _.filter(courseSections, function(sec) {
            return _.get(sec, 'is_primary_section');
          });
        }
        return [];
      };
    },
    templateUrl: 'directives/academics_class_info_final_exams.html'
  };
});

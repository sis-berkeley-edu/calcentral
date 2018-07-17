'use strict';

var angular = require('angular');
var _ = require('lodash');

angular.module('calcentral.controllers').controller('finalExamScheduleController', function(academicsFactory, $scope) {
  $scope.finalExams = {
    semesters: [],
    changeNotice: false,
    conflictFound: false,
    lawCoursesPresent: false,
    gradCoursesPresent: false,
    gradCoursesOnlyPresent: false,
    guidelinesLink: 'https://registrar.berkeley.edu/scheduling/academic-scheduling/final-exam-guide-schedules',
    lawExamLink: 'https://www.law.berkeley.edu/php-programs/students/exams/examTimesList.php'
  };

  // TODO: Move career parsing to back-end
  var detectLawAndGradCourses = function(semesters) {
    var currentAndFutureExamSemesters = getCurrentAndFutureExamSemesters(semesters);
    var academicCareerCodes = getSemesterCourseAcademicCareerCodes(currentAndFutureExamSemesters);
    var uniqueAcademicCareerCodes = _.uniq(academicCareerCodes);
    var ugrdPresent = _.includes(uniqueAcademicCareerCodes, 'UGRD');
    var lawPresent = _.includes(uniqueAcademicCareerCodes, 'LAW');
    var gradPresent = _.includes(uniqueAcademicCareerCodes, 'GRAD');
    $scope.finalExams.lawCoursesPresent = lawPresent;
    $scope.finalExams.gradCoursesPresent = gradPresent;
    $scope.finalExams.gradCoursesOnlyPresent = (gradPresent && !lawPresent && !ugrdPresent);
  };

  var getSemesterCourseAcademicCareerCodes = function(semesters) {
    var allCourses = getSemesterCourses(semesters);
    return _.map(allCourses, 'academicCareer');
  };

  var getSemesterCourses = function(semesters) {
    var allCourses = [];
    _.forEach(semesters, function(semester) {
      var semesterClasses = _.get(semester, 'classes', []);
      allCourses = _.concat(allCourses, semesterClasses);
    });
    return allCourses;
  };

  var getCurrentAndFutureExamSemesters = function(semesters) {
    return _.filter(semesters, function(semester) {
      var termCode = _.get(semester, 'termCode');
      var timeBucket = _.get(semester, 'timeBucket');
      return (termCode !== 'C' && timeBucket !== 'past');
    });
  };

  var detectSemesterTimeConflicts = function() {
    var semesters = _.get($scope, 'finalExams.semesters', []);
    var conflictFound = _.find(semesters, function(semester) {
      var exams = _.get(semester, 'examSchedule', []);
      return _.find(exams, function(e) {
        return e.timeConflict;
      });
    });
    $scope.finalExams.conflictFound = !!(conflictFound);
  };

  var parseAcademics = function(academics) {
    var semesters = _.get(academics, 'data.semesters');
    $scope.finalExams.semesters = _.filter(semesters, function(semester) {
      var semesterExamScheduleLength = _.get(semester, 'examSchedule.length');
      return (semesterExamScheduleLength > 0);
    });
    detectLawAndGradCourses(semesters);
    detectSemesterTimeConflicts();
  };

  var loadExamSemesters = function() {
    academicsFactory.getAcademics().then(parseAcademics);
  };

  loadExamSemesters();
});

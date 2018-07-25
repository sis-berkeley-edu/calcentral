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

  var detectCourseCareers = function(semesters) {
    var currentAndFutureExamSemesters = getCurrentAndFutureExamSemesters(semesters);
    var academicCareerCodes = getSemesterCourseAcademicCareerCodes(currentAndFutureExamSemesters);
    var ugrdPresent = _.includes(academicCareerCodes, 'UGRD');
    var lawPresent = _.includes(academicCareerCodes, 'LAW');
    var gradPresent = _.includes(academicCareerCodes, 'GRAD');
    $scope.finalExams.ugrdCoursesPresent = ugrdPresent;
    $scope.finalExams.lawCoursesPresent = lawPresent;
    $scope.finalExams.gradCoursesPresent = gradPresent;
    $scope.finalExams.gradCoursesOnlyPresent = (gradPresent && !lawPresent && !ugrdPresent);
    $scope.finalExams.coursesPresent = (ugrdPresent || gradPresent || lawPresent);
  };

  var getSemesterCourseAcademicCareerCodes = function(semesters) {
    var allCourseCareerCodes = [];
    _.forEach(semesters, function(semester) {
      var semesterCareerCodes = _.get(semester, 'exams.courseCareerCodes', []);
      allCourseCareerCodes = _.concat(allCourseCareerCodes, semesterCareerCodes);
    });
    return _.uniq(_.flatten(allCourseCareerCodes));
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
      var exams = _.get(semester, 'exams.schedule', []);
      return _.find(exams, function(e) {
        return e.timeConflict;
      });
    });
    $scope.finalExams.conflictFound = !!(conflictFound);
  };

  var parseAcademics = function(academics) {
    var semesters = _.get(academics, 'data.semesters');
    $scope.finalExams.message = _.get(academics, 'data.examMessage');
    $scope.finalExams.semesters = _.filter(semesters, function(semester) {
      var semesterExamScheduleLength = _.get(semester, 'exams.schedule.length');
      return (semesterExamScheduleLength > 0);
    });
    detectCourseCareers(semesters);
    detectSemesterTimeConflicts();
  };

  var loadExamSemesters = function() {
    academicsFactory.getAcademics().then(parseAcademics);
  };

  loadExamSemesters();
});

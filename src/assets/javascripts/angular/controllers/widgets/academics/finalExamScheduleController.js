'use strict';


var _ = require('lodash');

angular.module('calcentral.controllers').controller('finalExamScheduleController', function(academicsFactory, apiService, $scope) {
  $scope.finalExams = {
    changeNotice: false,
    conflictFound: false,
    lawCoursesPresent: false,
    gradCoursesPresent: false,
    gradCoursesOnlyPresent: false,
    ugrdCoursesPresent: false,
    lawExamLink: 'https://www.law.berkeley.edu/php-programs/students/exams/examTimesList.php',
    guidelinesLink: 'https://registrar.berkeley.edu/scheduling/academic-scheduling/final-exam-guide-schedules',
    semesters: []
  };

  $scope.isFinalExamFeatureEnabled = function() {
    if (apiService.user.profile.features && $scope.finalExamMode) {
      return apiService.user.profile.features['finalExamSchedule' + capitalize($scope.finalExamMode)];
    } else {
      return false;
    }
  };

  var capitalize = function(s) {
    return s && s[0].toUpperCase() + s.slice(1);
  };

  var detectCourseCareers = function(semesters) {
    var currentAndFutureExamSemesters = getCurrentAndFutureExamSemesters(semesters);
    var academicCareerCodes = getSemesterCourseAcademicCareerCodes(currentAndFutureExamSemesters);
    var ugrdPresent = _.includes(academicCareerCodes, 'UGRD');
    var lawPresent = _.includes(academicCareerCodes, 'LAW');
    var gradPresent = _.includes(academicCareerCodes, 'GRAD');

    return {
      ugrdCoursesPresent: ugrdPresent,
      lawCoursesPresent: lawPresent,
      gradCoursesPresent: gradPresent,
      gradCoursesOnlyPresent: (gradPresent && !lawPresent && !ugrdPresent),
      coursesPresent: (ugrdPresent || gradPresent || lawPresent)
    };
  };

  var detectFinalizedSemesterExams = function(semesters) {
    _.forEach(semesters, function(semester) {
      var finalizedSchedule = _.find(_.get(semester, 'exams.schedule'), function(s) {
        return s.finalized === 'Y';
      });
      semester.schedulesFinalized = (finalizedSchedule !== undefined);
    });
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

  var loadExamSemesters = function() {
    academicsFactory.getAcademics().then(parseAcademics);
  };

  var detectSemesterTimeConflicts = function(semesters) {
    var conflictFound = _.find(semesters, function(semester) {
      var exams = _.get(semester, 'exams.schedule', []);
      return _.find(exams, function(e) {
        return e.timeConflict;
      });
    });
    return !!(conflictFound);
  };

  var parseAcademics = function(academics) {
    var semesters = [];
    var academicsNode = $scope.finalExamMode === 'instructor' ? 'teachingSemesters' : 'semesters';

    if ($scope.currentSemester !== undefined) {
      semesters = [$scope.currentSemester];
    } else {
      semesters = _.get(academics, 'data.' + academicsNode);
    }

    $scope.finalExams.semesters = parseSemesters(semesters);
    $scope.finalExams.conflictFound = detectSemesterTimeConflicts($scope.finalExams.semesters);
    angular.extend($scope.finalExams, detectCourseCareers(semesters));
    $scope.finalExams.message = _.get(academics, 'data.examMessage');
    detectFinalizedSemesterExams($scope.finalExams.semesters);
  };

  var parseSemesters = function(semesters) {
    return _.filter(semesters, function(semester) {
      var semesterExamScheduleLength = _.get(semester, 'exams.schedule.length');
      return (semesterExamScheduleLength > 0);
    });
  };

  loadExamSemesters();
});

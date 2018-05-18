'use strict';

var angular = require('angular');
var _ = require('lodash');

angular.module('calcentral.controllers').controller('AcademicSummaryController', function(academicsFactory, academicsService, apiService, linkService, profileFactory, $route, $scope) {
  apiService.util.setTitle('Academic Summary');
  linkService.addCurrentRouteSettings($scope);
  $scope.academicSummary = {
    isLoading: true,
    showSemesters: false
  };
  $scope.printPage = function() {
    apiService.util.printPage();
  };

  var mergeTermHonors = function(semester) {
    var honors = $scope.collegeAndLevel.awardHonors[semester.termId] || [];
    semester.honors = _.keyBy(honors, function(honor) {
      return honor.code;
    });
  };

  var parseTransferCredit = function(response) {
    $scope.transferCredits = _.get(response, 'data');
  };

  var hasPoints = function(classSection) {
    return _.some(classSection.sections, function(section) {
      return section.grading.gradePoints;
    });
  };

  var parseSemester = function(semester) {
    semester.showGradePoints = _.some(semester.classes, hasPoints);
  };

  var parseSemesters = function(semesters) {
    if (!!(semesters.length && apiService.user.profile.hasStudentHistory)) {
      $scope.showSemesters = true;
      _.each(semesters, parseSemester);
    }
  };

  var parseGpaUnits = function(gpaUnits) {
    var unitRows = _.compact(_.values(_.pick(gpaUnits, 'totalUnits', 'totalLawUnits', 'totalTransferAndTestingUnits', 'totalUnitsTakenNotForGpa', 'totalUnitsPassedNotForGpa')));
    $scope.gpaUnits = academicsService.parseGpaUnits(gpaUnits);
    $scope.gpaUnits.rowCount = unitRows.length;
  };

  var parseTermHonors = function() {
    _.each($scope.semesters, mergeTermHonors);
  };

  var parseTermUnits = function() {
    _.each($scope.semesters, function(semester) {
      var showUnitTotal = _.some(semester.classes, function(klass) {
        var classCareer = _.get(klass, 'academicCareer');
        return (classCareer === 'GRAD') || (classCareer === 'LAW');
      });
      semester.showUnitTotal = showUnitTotal;
    });
  };

  var parseAcademics = function(response) {
    angular.extend($scope, _.get(response, 'data'));
    $scope.showGpa = academicsService.showGpa($scope.gpaUnits.gpa);
    parseGpaUnits(_.get(response, 'data.gpaUnits'));
    parseSemesters(_.get(response, 'data.semesters'));
    parseTermHonors();
    parseTermUnits();
  };

  var parsePerson = function(response) {
    var names = _.get(response, 'data.feed.student.names');
    $scope.primaryName = apiService.profile.findPrimary(names);
  };

  $scope.showTransferCreditPoints = function(career) {
    if (career === 'law') {
      return false;
    }
    return _.some($scope.transferCredits[career].detailed, function(credit) {
      return (_.get(credit, 'gradePoints')) > 0;
    });
  };
  $scope.hasTestUnits = function(career) {
    if (career !== 'undergraduate') {
      return false;
    }
    var testCredits = _.values(_.pick($scope.transferCredits[career].summary, ['apTestUnits', 'ibTestUnits', 'alevelTestUnits']));
    return _.some(testCredits, function(testCredit) {
      return testCredit > 0;
    });
  };

  // Similar to academicsController, we wait until user profile is fully loaded before hitting academics data
  $scope.$on('calcentral.api.user.isAuthenticated', function(event, isAuthenticated) {
    if (isAuthenticated) {
      $scope.canViewAcademics = apiService.user.profile.hasAcademicsTab;
      academicsFactory.getAcademics()
      .then(parseAcademics)
      .then(academicsFactory.getTransferCredit)
      .then(parseTransferCredit)
      .then(profileFactory.getPerson)
      .then(parsePerson)
      .finally(function() {
        $scope.academicSummary.isLoading = false;
      });
    }
  });
});

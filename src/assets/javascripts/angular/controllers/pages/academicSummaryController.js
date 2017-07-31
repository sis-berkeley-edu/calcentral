'use strict';

var angular = require('angular');
var _ = require('lodash');

angular.module('calcentral.controllers').controller('AcademicSummaryController', function(academicsFactory, academicsService, apiService, linkService, profileFactory, $route, $scope) {
  apiService.util.setTitle('Academic Summary');
  linkService.addCurrentRouteSettings($scope);
  $scope.academicSummary = {
    isLoading: true
  };
  $scope.expectedGradTerm = academicsService.expectedGradTerm;
  $scope.printPage = function() {
    apiService.util.printPage();
  };

  var showSemesters = function() {
    return !!(_.get($scope, 'semesters.length') && apiService.user.profile.hasStudentHistory);
  };

  var showTransferCredit = function() {
    return !!(_.get($scope, 'transferCredit.ucTransferCrseSch.unitsTotal') || _.get('transferCredit.ucTestComponent.totalTestUnits'));
  };

  var showTransferCreditPoints = function(creditItems) {
    // If one transfer credit institution includes a 'ucbGradePoints' value, show the Points column.  Otherwise, hide it.
    return !!_.find(creditItems, function(credit) {
      return (_.get(credit, 'ucbGradePoints') > 0);
    });
  };

  var parseGpaUnits = function() {
    // Testing units are lumped in with Transfer Units on the academic summary
    if ($scope.gpaUnits && !$scope.gpaUnits.errored) {
      var unitsAdjusted = _.get($scope, 'transferCredit.ucTransferCrseSch.unitsAdjusted');
      var totalTestUnits = _.get($scope, 'transferCredit.ucTestComponent.totalTestUnits');
      var totalTransferAndTestingUnits = academicsService.totalTransferUnits(unitsAdjusted, totalTestUnits);
      _.set($scope.gpaUnits, 'testingAndTransferUnits', totalTransferAndTestingUnits);
    }
  };

  var parseTransferCredit = function() {
    $scope.showTransferCredit = showTransferCredit();
    if (!showTransferCredit) {
      return;
    } else {
      $scope.showPointsColumn = showTransferCreditPoints(_.get($scope, 'transferCredit.ucTransferCrseSch.items'));
    }
  };

  var mergeTermHonors = function(semester) {
    var honors = $scope.collegeAndLevel.awardHonors[semester.termId] || [];
    semester.honors = _.keyBy(honors, function(honor) {
      return honor.code;
    });
  };

  var parseTermHonors = function() {
    _.each($scope.semesters, mergeTermHonors);
  };

  var parseAcademics = function(response) {
    angular.extend($scope, _.get(response, 'data'));
    $scope.showSemesters = showSemesters();
    parseTermHonors();
    parseGpaUnits();
    parseTransferCredit();
  };

  var parsePerson = function(response) {
    var names = _.get(response, 'data.feed.student.names');
    $scope.primaryName = apiService.profile.findPrimary(names);
  };

  // Similar to academicsController, we wait until user profile is fully loaded before hitting academics data
  $scope.$on('calcentral.api.user.isAuthenticated', function(event, isAuthenticated) {
    if (isAuthenticated) {
      $scope.canViewAcademics = apiService.user.profile.hasAcademicsTab;
      academicsFactory.getAcademics()
      .then(parseAcademics)
      .then(profileFactory.getPerson)
      .then(parsePerson)
      .finally(function() {
        $scope.academicSummary.isLoading = false;
      });
    }
  });
});

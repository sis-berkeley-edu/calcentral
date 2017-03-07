'use strict';

var angular = require('angular');
var _ = require('lodash');

angular.module('calcentral.controllers').controller('AcademicSummaryController', function(academicsFactory, academicsService, apiService, linkService, profileFactory, userService, $route, $scope) {
  apiService.util.setTitle('Academic Summary');
  linkService.addCurrentRouteSettings($scope);
  $scope.isAcademicSummary = $route.current.isAcademicSummary;
  $scope.academicSummary = {
    isLoading: true
  };
  $scope.expectedGradTerm = academicsService.expectedGradTerm;

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
      _.set($scope.gpaUnits, 'testingAndTransferUnits', $scope.gpaUnits.testingUnits + $scope.gpaUnits.transferUnitsAccepted);
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

  var parseAcademics = function(data) {
    angular.extend($scope, _.get(data, 'data'));
    parseGpaUnits();
    parseTransferCredit();
  };

  var parsePerson = function(data) {
    var names = _.get(data, 'data.feed.student.names');
    $scope.primaryName = apiService.profile.findPrimary(names);
  };

  // Similar to academicsController, we wait until user profile is fully loaded before hitting academics data
  $scope.$on('calcentral.api.user.isAuthenticated', function(event, isAuthenticated) {
    if (isAuthenticated) {
      $scope.canViewAcademics = userService.profile.hasAcademicsTab;
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

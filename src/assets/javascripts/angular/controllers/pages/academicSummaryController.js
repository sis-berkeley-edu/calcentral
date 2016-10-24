'use strict';

var angular = require('angular');
var _ = require('lodash');

angular.module('calcentral.controllers').controller('AcademicSummaryController', function(academicsFactory, apiService, userService, $route, $scope) {
  apiService.util.setTitle('Academic Summary');
  $scope.isAcademicSummary = $route.current.isAcademicSummary;
  $scope.academicSummary = {
    isLoading: true
  };

  var parseAcademics = function(data) {
    angular.extend($scope, data);

    $scope.pastSemestersLimit = 'Infinity';
    $scope.isProfileCurrent = !$scope.transitionTerm || $scope.transitionTerm.isProfileCurrent;
    // The isEmpty check will be true if collegeAndLevel.errored or collegeAndLevel.empty.
    $scope.showProfileMessage = (!$scope.isProfileCurrent || !$scope.collegeAndLevel || _.isEmpty($scope.collegeAndLevel.careers));

    // cumulativeGpa is passed as a string to maintain two significant digits
    $scope.gpaUnits.cumulativeGpaFloat = $scope.gpaUnits.cumulativeGpa;
    // Convert these to Number types to be processed regularly. `parseFloat` returns NaN if the input value does not contain at least one digit.
    $scope.gpaUnits.cumulativeGpa = parseFloat($scope.gpaUnits.cumulativeGpa);
    $scope.gpaUnits.totalUnits = parseFloat($scope.gpaUnits.totalUnits);
  };

  $scope.printPage = function() {
    apiService.util.printPage();
  };

  // Similar to academicsController, we wait until user profile is fully loaded before hitting academics data
  $scope.$on('calcentral.api.user.isAuthenticated', function(event, isAuthenticated) {
    if (isAuthenticated) {
      $scope.canViewAcademics = userService.profile.hasAcademicsTab;
      academicsFactory.getAcademics().success(parseAcademics);
    }
    $scope.academicSummary.isLoading = false;
  });
});

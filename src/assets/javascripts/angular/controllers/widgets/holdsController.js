'use strict';

var angular = require('angular');

/**
 * Holds controller
 */
angular.module('calcentral.controllers').controller('HoldsController', function(academicStatusFactory, $scope, $route) {
  $scope.holdsInfo = {
    isLoading: true
  };

  var loadHolds = function() {
    return academicStatusFactory.getHolds()
      .then(function(data) {
        $scope.holds = data.holds;
      })
      .finally(function() {
        $scope.holdsInfo.isLoading = false;
      });
  };

  var init = function() {
    if ($route.current.isAdvisingStudentLookup) {
      $scope.holds = $scope.$parent.holds;
      $scope.holdsInfo = $scope.$parent.holdsInfo;
    } else {
      loadHolds();
    }
  };

  init();
});

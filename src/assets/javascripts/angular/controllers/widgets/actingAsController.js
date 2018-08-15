'use strict';

/**
 * 'Acting as' controller
 */
angular.module('calcentral.controllers').controller('ActingAsController', function(adminFactory, apiService, $scope) {
  $scope.admin = {};

  /**
   * Stop acting as someone else
   */
  $scope.admin.stopActAs = function() {
    adminFactory.stopActAs().then(apiService.util.redirectToToolbox);
  };

  $scope.admin.stopAdvisorActAs = function() {
    adminFactory.stopAdvisorActAs().then(apiService.util.redirectToHome);
  };

  /**
   * Delegate is done acting-as
   */
  $scope.admin.stopDelegateActAs = function() {
    adminFactory.stopDelegateActAs().then(apiService.util.redirectToToolbox);
  };
});

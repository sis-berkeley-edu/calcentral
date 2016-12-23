'use strict';

var angular = require('angular');

/**
 * Dashboard controller
 */
angular.module('calcentral.controllers').controller('DashboardController', function($scope, apiService) {

  var init = function() {
    if (apiService.user.profile.hasDashboardTab) {
      apiService.util.setTitle('Dashboard');
    } else {
      apiService.user.redirectToHome();
    }
  };

  // We have to watch the user profile for changes because of async loading in
  // case of Back button navigation from a different (non-CalCentral) location.
  $scope.$watch('api.user.profile.hasDashboardTab', init);
});

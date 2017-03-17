'use strict';

var angular = require('angular');

/**
 * Splash controller
 */
angular.module('calcentral.controllers').controller('SplashController', function(apiService, serviceAlertsFactory, $filter, $scope) {
  apiService.util.setTitle('Home');

  serviceAlertsFactory.getAlerts().then(
    function successCallback(response) {
      if (response.data && response.data.alert && response.data.alert.title) {
        $scope.splashNote = response.data.alert;
      } else {
        $scope.splashNote = response.data.releaseNote;
      }
    }
  );
});

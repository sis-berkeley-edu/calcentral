'use strict';

var angular = require('angular');

/**
 * Alerts controller
 */
angular.module('calcentral.controllers').controller('AlertsController', function(serviceAlertsFactory, $scope) {
  var fetch = function(options) {
    serviceAlertsFactory.getAlerts(options).then(function successCallback(response) {
      $scope.alert = response.data.alert;
    });
  };

  fetch();
});

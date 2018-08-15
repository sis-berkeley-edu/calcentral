'use strict';

/**
 * CalCentral update page controller
 */
angular.module('calcentral.controllers').controller('CalCentralUpdateController', function(apiService, serviceAlertsFactory, $scope) {
  var handleAlertSuccess = function(data) {
    angular.extend($scope.update, data.data);
    $scope.update.isLoading = false;
  };

  var handleAlertError = function() {
    $scope.update.isLoading = false;
  };

  var getUpdate = function() {
    $scope.update = {
      isLoading: true
    };
    serviceAlertsFactory.getAlerts().then(handleAlertSuccess, handleAlertError);
  };

  apiService.util.setTitle('CalCentral Update');
  getUpdate();
});

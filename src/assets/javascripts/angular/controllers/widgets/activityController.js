'use strict';

/**
 * Activity controller
 */
angular.module('calcentral.controllers').controller('ActivityController', function(activityFactory, apiService, dateService, $scope) {
  var getMyActivity = function(options) {
    $scope.activityInfo = {
      isLoading: true
    };
    activityFactory.getActivity(options).then(function(data) {
      angular.extend($scope, data);
      $scope.activityInfo.isLoading = false;
    });
  };

  getMyActivity();
});

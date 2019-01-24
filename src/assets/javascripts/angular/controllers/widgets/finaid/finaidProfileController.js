'use strict';

var _ = require('lodash');

angular.module('calcentral.controllers').controller('FinaidProfileController', function(finaidProfileFactory, $scope, $routeParams) {
  $scope.finaidProfile = {
    isLoading: true
  };

  var getFinaidProfile = function(options) {
    return finaidProfileFactory.getFinaidProfile(options).then(
      function successCallback(response) {
        var finaidProfile = _.get(response, 'data.finaidProfile');
        $scope.finaidProfile = finaidProfile;
        if ($scope.finaidProfile.categories[0]) {
          _.set($scope.finaidProfile.categories[0], 'show', true);
        }
        $scope.finaidProfile.isLoading = false;
      }
    );
  };

  getFinaidProfile({finaidYear: $routeParams.finaidYearId});
});

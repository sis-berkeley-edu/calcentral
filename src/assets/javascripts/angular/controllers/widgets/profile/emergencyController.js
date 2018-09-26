'use strict';

var _ = require('lodash');

/**
 * Emergency controller
 */
angular.module('calcentral.controllers').controller('EmergencyController', function(profileFactory, $scope) {
  $scope.emergencyContactInformation = {
    isLoading: true,
    isErrored: false
  };

  var loadInformation = function() {
    profileFactory.getPerson()
    .then(function(response) {
      $scope.emergencyContactInformation.isLoading = false;
      $scope.emergencyContactInformation.isErrored = _.get(response, 'data.errored');
    });
  };

  loadInformation();
});

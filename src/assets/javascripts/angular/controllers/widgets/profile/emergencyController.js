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

  var parseEmergencyContactInformation = function(response) {
    $scope.emergencyContactInformation.isErrored = _.get(response, 'data.errored');
    $scope.emergencyContactInformation.editLink = _.get(response, 'data.feed.links.editEmergencyContactInformation');
  };

  var loadInformation = function() {
    profileFactory.getPerson()
    .then(parseEmergencyContactInformation).finally(function() {
      $scope.emergencyContactInformation.isLoading = false;
    });
  };

  loadInformation();
});

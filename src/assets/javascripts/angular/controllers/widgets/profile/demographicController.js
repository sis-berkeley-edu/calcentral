'use strict';

var _ = require('lodash');

/**
 * Demographic controller
 */
angular.module('calcentral.controllers').controller('DemographicController', function(profileFactory, $scope) {
  $scope.demographicInformation = {
    isLoading: true,
    isErrored: false
  };

  var parseDemographicInformation = function(response) {
    $scope.demographicInformation.isErrored = _.get(response, 'data.errored');
    $scope.demographicInformation.editLink = _.get(response, 'data.feed.links.editDemographicInformation');
  };

  var loadInformation = function() {
    profileFactory.getPerson()
    .then(parseDemographicInformation)
    .finally(function() {
      $scope.demographicInformation.isLoading = false;
    });
  };

  loadInformation();
});

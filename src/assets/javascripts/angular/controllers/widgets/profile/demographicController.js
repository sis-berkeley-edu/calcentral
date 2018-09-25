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

  var loadInformation = function() {
    profileFactory.getPerson()
    .then(function(response) {
      $scope.demographicInformation.isLoading = false;
      $scope.demographicInformation.isErrored = _.get(response, 'data.errored');
    });
  };

  loadInformation();
});

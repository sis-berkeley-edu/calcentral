'use strict';

var _ = require('lodash');

/**
 * Contact controller
 */
angular.module('calcentral.controllers').controller('ContactController', function(profileFactory, $scope) {
  $scope.contactInformation = {
    isLoading: true,
    isErrored: false
  };

  var loadInformation = function() {
    profileFactory.getPerson()
    .then(function(response) {
      $scope.contactInformation.isLoading = false;
      $scope.contactInformation.isErrored = _.get(response, 'data.errored');
    });
  };

  loadInformation();
});

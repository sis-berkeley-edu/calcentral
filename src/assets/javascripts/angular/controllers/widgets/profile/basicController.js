'use strict';

var _ = require('lodash');

/**
 * Basic profile controller
 */
angular.module('calcentral.controllers').controller('BasicController', function(profileFactory, $scope) {
  $scope.basicInformation = {
    isLoading: true,
    isErrored: false
  };

  var loadInformation = function() {
    profileFactory.getPerson().then(function(response) {
      $scope.basicInformation.isLoading = false;
      $scope.basicInformation.isErrored = _.get(response, 'data.errored');
    });
  };

  loadInformation();
});

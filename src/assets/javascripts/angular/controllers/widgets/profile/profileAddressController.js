'use strict';

var angular = require('angular');
var _ = require('lodash');

/**
 * Profile Address controller
 */
angular.module('calcentral.controllers').controller('ProfileAddressController', function(apiService, profileFactory, $scope) {
  angular.extend($scope, {
    items: {
      content: []
    }
  });

  var parsePerson = function(response) {
    apiService.profile.parseSection($scope, response, 'addresses');
    $scope.items.content = apiService.profile.fixFormattedAddresses($scope.items.content);
  };

  var loadInformation = function(options) {
    $scope.isLoading = true;
    profileFactory.getPerson({
      refreshCache: _.get(options, 'refresh')
    })
    .then(parsePerson)
    .then(function() {
      $scope.isLoading = false;
    });
  };

  loadInformation();
});

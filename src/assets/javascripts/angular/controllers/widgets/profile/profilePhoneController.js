'use strict';

var angular = require('angular');
var _ = require('lodash');

/**
 * Profile Phone controller
 */
angular.module('calcentral.controllers').controller('ProfilePhoneController', function(apiService, profileFactory, $scope) {
  angular.extend($scope, {
    items: {
      content: []
    }
  });

  var parsePerson = function(response) {
    apiService.profile.parseSection($scope, response, 'phones');
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

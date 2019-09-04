'use strict';

var _ = require('lodash');

/**
 * Preferred Name Controller
 */
angular.module('calcentral.controllers').controller('BasicPreferredNameController', function(apiService, profileFactory, $scope) {
  angular.extend($scope, {
    items: {
      content: []
    },
    primary: {}
  });

  var parsePerson = function(data) {
    var person = data.data.feed;
    var preferredName = apiService.profile.findPreferred(person.names);
    $scope.primary = apiService.profile.findPrimary(person.names);
    angular.extend($scope, {
      items: {
        content: [preferredName]
      }
    });
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

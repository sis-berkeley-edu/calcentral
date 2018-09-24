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

  var parsePerson = function(response) {
    $scope.basicInformation.editLink = _.get(response, 'data.feed.links.editProfile');
    $scope.basicInformation.isErrored = _.get(response, 'data.errored');
  };

  var loadInformation = function() {
    profileFactory.getPerson()
    .then(parsePerson)
    .finally(function() {
      $scope.basicInformation.isLoading = false;
    });
  };

  loadInformation();
});

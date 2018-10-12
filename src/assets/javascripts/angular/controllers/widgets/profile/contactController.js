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

  var parseContactInformation = function(response) {
    $scope.contactInformation.isErrored = _.get(response, 'data.errored');
    $scope.contactInformation.editLink = _.get(response, 'data.feed.links.editContactInformation');
  };

  var loadInformation = function() {
    profileFactory.getPerson()
    .then(parseContactInformation)
    .finally(function() {
      $scope.contactInformation.isLoading = false;
    });
  };

  loadInformation();
});

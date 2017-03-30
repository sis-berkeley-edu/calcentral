'use strict';

var _ = require('lodash');
var angular = require('angular');

/**
 * Controller for users wanting to manage delegates
 */
angular.module('calcentral.controllers').controller('DelegateController', function(delegateFactory, $scope) {
  $scope.delegate = {
    isLoading: true
  };

  var loadInformation = function() {
    delegateFactory.getManageDelegatesURL().then(function(response) {
      angular.extend($scope, _.get(response, 'data.feed.root'));
      $scope.delegate.isLoading = false;
    });
  };

  loadInformation();
});

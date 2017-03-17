'use strict';

var angular = require('angular');
var _ = require('lodash');

/**
 * Basic Authentication controller
 */
angular.module('calcentral.controllers').controller('BasicAuthController', function(basicAuthFactory, $scope) {
  $scope.basicauth = {
    user: null
  };

  $scope.basicauth.connect = function() {
    basicAuthFactory.login().then(
      function successCallback(response) {
        var status = _.get(response, 'status');
        if (status < 200 || status >= 300) {
          return;
        }
        window.location = '/';
      }
    );
  };

  $scope.basicauth.disconnect = function() {
    $scope.basicauth.user = null;
  };

  $scope.$watch('basicauth.login + basicauth.password', function() {
    basicAuthFactory.updateHeaders($scope.basicauth);
  });
});

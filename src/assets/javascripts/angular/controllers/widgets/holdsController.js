'use strict';

var angular = require('angular');
var _ = require('lodash');

/**
 * Holds controller
 */
angular.module('calcentral.controllers').controller('HoldsController', function(holdsFactory, $scope, $route) {
  $scope.holdsInfo = {
    isLoading: true
  };

  var init = function(options) {
    holdsFactory.getHolds(options).then(function(data) {
      $scope.holdsInfo.isLoading = false;
      $scope.holds = _.get(data, 'data.feed');
    });

    if ($route.current.isAdvisingStudentLookup) {
      $scope.holds = $scope.$parent.holds;
      $scope.holdsInfo = $scope.$parent.holdsInfo;
    }
  };

  init();
});

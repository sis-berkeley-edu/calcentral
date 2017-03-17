'use strict';

var angular = require('angular');
var _ = require('lodash');

/**
 * Holds controller
 */
angular.module('calcentral.controllers').controller('HoldsController', function(academicStatusFactory, $scope) {
  $scope.holdsInfo = {
    isLoading: true
  };

  var loadHolds = function() {
    return academicStatusFactory.getHolds().then(function(parsedHolds) {
      $scope.holds = _.get(parsedHolds, 'holds');
    }).finally(function() {
      $scope.holdsInfo.isLoading = false;
    });
  };

  loadHolds();
});

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
    return academicStatusFactory.getHolds()
      .then(function(data) {
        $scope.holds = _.get(data, 'holds');
      })
      .finally(function() {
        $scope.holdsInfo.isLoading = false;
      });
  };

  loadHolds();
});

'use strict';

var _ = require('lodash');

/**
 * Standings controller
 */
angular.module('calcentral.controllers').controller('AcademicStandingController', function(academicStandingsFactory, $scope) {
  $scope.standingInfo = {
    isLoading: true
  };

  var loadStandings = function() {
    return academicStandingsFactory.getStandings().then(function(response) {
      $scope.standings = _.get(response, 'data.feed');
    }).finally(function() {
      $scope.standingInfo.isLoading = false;
    });
  };

  loadStandings();
});

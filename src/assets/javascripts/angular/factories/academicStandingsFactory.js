'use strict';

var angular = require('angular');

/**
 * Standings Factory
 */
angular.module('calcentral.factories').factory('academicStandingsFactory', function(apiService) {
  var urlStandings = '/api/my/standings';
  // var urlStandings = '/dummy/json/standings_present.json';

  var getStandings = function(options) {
    return apiService.http.request(options, urlStandings);
  };

  return {
    getStandings: getStandings
  };
});

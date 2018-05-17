'use strict';

var angular = require('angular');

/**
 * Standings Factory
 */
angular.module('calcentral.factories').factory('academicStandingsFactory', function(apiService, $route, $routeParams) {
  var urlStandings = '/api/my/standings';
  // var urlStandings = '/dummy/json/standings_present.json';
  var urlAdvisingStudentStandings = '/api/advising/standings/';
  // var urlAdvisingStudentHolds = '/dummy/json/standings_present.json';

  var getStandings = function(options) {
    var url = $route.current.isAdvisingStudentLookup ? urlAdvisingStudentStandings + $routeParams.uid : urlStandings;
    return apiService.http.request(options, url);
  };

  return {
    getStandings: getStandings
  };
});

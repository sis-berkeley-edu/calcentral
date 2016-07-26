'use strict';

var angular = require('angular');

/**
 * Holds Factory
 */
angular.module('calcentral.factories').factory('holdsFactory', function(apiService, $route, $routeParams) {
  // var url = '/dummy/json/holds_empty.json';
  // var url = '/dummy/json/holds_present.json';
  var urlHolds = '/api/campus_solutions/holds';
  var urlAdvisingStudentHolds = '/api/advising/holds/';

  var getHolds = function(options) {
    var url = $route.current.isAdvisingStudentLookup ? urlAdvisingStudentHolds + $routeParams.uid : urlHolds;
    return apiService.http.request(options, url);
  };

  return {
    getHolds: getHolds
  };
});

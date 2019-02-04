'use strict';

/**
 * Holds Factory
 */
angular.module('calcentral.factories').factory('holdsFactory', function(apiService, $route, $routeParams) {
  var urlHolds = '/api/my/holds';
  // var urlHolds = '/dummy/json/holds_empty.json';
  // var urlHolds = '/dummy/json/holds_errored.json';
  // var urlHolds = '/dummy/json/holds_present.json';
  var urlAdvisingStudentHolds = '/api/advising/holds/';
  // var urlAdvisingStudentHolds = '/dummy/json/holds_present.json';

  var getHolds = function(options) {
    var url = $route.current.isAdvisingStudentLookup ? urlAdvisingStudentHolds + $routeParams.uid : urlHolds;
    return apiService.http.request(options, url);
  };

  return {
    getHolds: getHolds
  };
});

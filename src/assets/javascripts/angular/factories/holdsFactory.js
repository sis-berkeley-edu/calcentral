'use strict';

var _ = require('lodash');
var angular = require('angular');

/**
 * Holds Factory
 */
angular.module('calcentral.factories').factory('holdsFactory', function(apiService, $route, $routeParams) {
  var urlHolds = '/api/my/holds';
  // var urlHolds = '/dummy/json/holds_errored.json';
  // var urlHolds = '/dummy/json/holds_present.json';
  var urlAdvisingStudentHolds = '/api/advising/holds/';
  // var urlAdvisingStudentHolds = '/dummy/json/holds_present.json';

  var parseHolds = function(response) {
    var holds = _.get(response, 'data.feed.holds');
    var isError = _.get(response, 'data.errored');
    return {
      holds: holds || [],
      isError: isError
    };
  };

  var fetch = function(options) {
    var url = $route.current.isAdvisingStudentLookup ? urlAdvisingStudentHolds + $routeParams.uid : urlHolds;
    return apiService.http.request(options, url);
  };

  var getHolds = function(options) {
    return fetch(options).then(parseHolds);
  };

  return {
    getHolds: getHolds
  };
});

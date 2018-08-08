'use strict';



/**
 * SIR Factory
 */
angular.module('calcentral.factories').factory('sirFactory', function(apiService, $http) {
  var urlHigherOne = '/api/campus_solutions/higher_one_url';
  var urlSirResponse = '/api/campus_solutions/sir_response';
  var urlSirStatuses = '/api/my/sir_statuses';
  // var urlSirStatusesInitiated = '/dummy/json/sir_statuses_initiated.json';
  // var urlSirStatusesReceived = '/dummy/json/sir_statuses_received.json';
  // var urlSirStatusesCompleted = '/dummy/json/sir_statuses_completed.json';

  var getHigherOneUrl = function(options) {
    return apiService.http.request(options, urlHigherOne);
  };
  var getSirStatuses = function(options) {
    return apiService.http.request(options, urlSirStatuses);
  };

  var postSirResponse = function(params) {
    return $http.post(urlSirResponse, params);
  };

  return {
    getHigherOneUrl: getHigherOneUrl,
    getSirStatuses: getSirStatuses,
    postSirResponse: postSirResponse
  };
});

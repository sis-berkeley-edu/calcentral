'use strict';

var angular = require('angular');

/**
 * SIR Factory
 */
angular.module('calcentral.factories').factory('sirFactory', function(apiService, $http) {
  var urlDeposit = '/api/campus_solutions/deposit';
  var urlHigherOne = '/api/campus_solutions/higher_one_url';
  var urlSirResponse = '/api/campus_solutions/sir_response';
  var urlSirStatuses = '/api/my/sir_statuses';
  // var urlSirStatuses = '/dummy/json/sir_statuses.json';

  var getDeposit = function(options) {
    return apiService.http.request(options, urlDeposit);
  };
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
    getDeposit: getDeposit,
    getHigherOneUrl: getHigherOneUrl,
    getSirStatuses: getSirStatuses,
    postSirResponse: postSirResponse
  };
});

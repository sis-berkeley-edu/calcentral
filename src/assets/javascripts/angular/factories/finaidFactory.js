'use strict';

var angular = require('angular');

/**
 * Financial Aid Factory
 */
angular.module('calcentral.factories').factory('finaidFactory', function(apiService, $http) {
  var urlAwards = '/api/campus_solutions/financial_aid_funding_sources';
  // var urlAwards = '/dummy/json/financial_aid_funding_sources.json';

  var urlAwardsTerm = '/api/campus_solutions/financial_aid_funding_sources_term';

  var urlCompareAwardsCurrent = '/api/campus_solutions/financial_aid_compare_awards_current';
  var urlCompareAwardsList = '/api/campus_solutions/financial_aid_compare_awards_list';
  var urlCompareAwardsPrior = '/api/campus_solutions/financial_aid_compare_awards_prior';

  var urlFinaidYear = '/api/campus_solutions/financial_aid_data';
  // var urlFinaidYear = '/dummy/json/financial_aid_data.json';
  // var urlFinaidYear = '/dummy/json/financial_aid_data_summer_only.json';
  var urlSummary = '/api/campus_solutions/aid_years';
  // var urlSummary = '/dummy/json/finaid_summary.json';

  var urlPostTC = '/api/campus_solutions/terms_and_conditions';
  var urlPostT4 = '/api/campus_solutions/title4';

  var getAwards = function(options) {
    return apiService.http.request(options, urlAwards + '?aid_year=' + options.finaidYearId);
  };
  var getAwardsTerm = function(options) {
    return apiService.http.request(options, urlAwardsTerm + '?aid_year=' + options.finaidYearId);
  };

  var getAwardCompareCurrent = function(options) {
    return apiService.http.request(options, urlCompareAwardsCurrent +
      '?aid_year=' + options.finaidYearId
    );
  };
  var getAwardCompareList = function(options) {
    return apiService.http.request(options, urlCompareAwardsList +
      '?aid_year=' + options.finaidYearId
    );
  };
  var getAwardComparePrior = function(options) {
    return apiService.http.request(options, urlCompareAwardsPrior +
      '?aid_year=' + options.finaidYearId +
      '&date=' + options.date
    );
  };

  var getFinaidYearInfo = function(options) {
    return apiService.http.request(options, urlFinaidYear + '?aid_year=' + options.finaidYearId);
  };
  var getSummary = function(options) {
    return apiService.http.request(options, urlSummary);
  };

  var postTCResponse = function(finaidYearId, response) {
    return $http.post(urlPostTC, {
      aidYear: finaidYearId,
      response: response
    });
  };
  var postT4Response = function(response) {
    return $http.post(urlPostT4, {
      response: response
    });
  };

  return {
    getAwards: getAwards,
    getAwardsTerm: getAwardsTerm,
    getAwardCompareCurrent: getAwardCompareCurrent,
    getAwardCompareList: getAwardCompareList,
    getAwardComparePrior: getAwardComparePrior,
    getFinaidYearInfo: getFinaidYearInfo,
    getSummary: getSummary,
    postTCResponse: postTCResponse,
    postT4Response: postT4Response
  };
});
